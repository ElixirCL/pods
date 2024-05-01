defmodule Pods do
  @moduledoc """
    Core Pods. Handles the communication to the Pod process and the Pod Client
  """
  require Logger

  # MARK: - Private Helpers
  defp get(registry, module) do
    Map.get(registry.pods, module)
  end

  defp os_type() do
    {type, os} = :os.type()
    arch = to_string(:erlang.system_info(:system_architecture))

    %{
      type: type,
      os: os,
      arch: arch
    }
  end

  # comply with the protocol. the first command when load is ready must be describe
  defp pod_is_ready(pod, manager, encoder, handler) do
    payload = %{
      op: "describe",
      id: UUIDv7.generate()
    }

    message = encoder.encode!(payload, "bencode")

    params = %{
      op: payload.op,
      id: payload.id,
      pod: pod,
      message: message,
      command: "",
      args: [],
      result: %{}
    }

    handler.event(params, :before_op)

    handler.event(
      Map.merge(params, %{result: manager.send(pod, message)}),
      :ready
    )
  end

  # MARK: - Public API
  def start(pod_modules, manager, encoder, decoder, handler) do
    manager.init()

    pods_with_pids =
      Enum.map(pod_modules, fn module ->
        pod = module.setup()

        out_handler = fn %{origin: _origin, pid: pid, response: response} = raw ->
          # First we check the response, must be bencode encoded.
          decoded_response = decoder.decode!(response, "bencode")

          # Get the id of the response
          id = Map.get(decoded_response, "id", pid)

          # Now we check the status.
          status =
            case Map.get(decoded_response, "status") do
              nil ->
                :ok

              value ->
                case List.first(value) do
                  "done" -> :ok
                  "ok" -> :ok
                  _ -> :error
                end
            end

          # We decode the result with the module format
          result =
            case Map.get(decoded_response, "value") do
              nil -> []
              value -> decoder.decode!(value, module.manifest().format())
            end

          payload = %{
            raw: raw,
            id: id,
            status: status,
            pod: Map.merge(pod, %{pid: pid}),
            result: result
          }

          case status do
            :ok ->
              handler.success(payload)

            :error ->
              error =
                case Map.get(decoded_response, "error") do
                  nil -> []
                  value -> decoder.decode!(value, module.manifest().format())
                end

              handler.error(Map.merge(payload, %{error: error}))
          end
        end

        exception_handler = fn raw ->
          # triggers the exception without decoding
          # since we cannot assume the exception is encoded with bencode
          handler.exception(raw)
        end

        executable = module.manifest().executable(os_type())
        opts = module.manifest().opts()

        case manager.start(executable, decoder, out_handler, exception_handler, opts) do
          {:ok, pid} ->
            pod_with_pid = Map.merge(pod, %{pid: pid})

            pod_is_ready(pod_with_pid, manager, encoder, handler)

            %{
              "#{to_string(module)}": pod_with_pid
            }

          {:error, reason} = error ->
            Logger.error("Error Starting #{executable} #{opts}")
            Logger.error(reason)
            handler.exception(error)
            # Empty pod since its not started
            %{}
        end
      end)
      |> Enum.reduce(%{}, fn item, acc -> Map.merge(acc, item) end)

    %{
      pods: pods_with_pids,
      manager: manager,
      encoder: encoder,
      decoder: decoder,
      handler: handler
    }
  end

  # MARK: - Pod API Helpers

  # MARK: Operand Calls
  defp call(registry, module, op) do
    payload = %{
      op: op,
      id: UUIDv7.generate()
    }

    Logger.info("Call operand in Pod")
    Logger.debug(%{payload: payload, module: module})

    message = registry.encoder.encode!(payload, "bencode")

    pod = get(registry, module)

    params = %{
      op: payload.op,
      id: payload.id,
      pod: pod,
      message: message,
      command: "",
      args: [],
      result: %{}
    }

    registry.handler.event(params, :before_op)

    registry.handler.event(
      Map.merge(params, %{result: registry.manager.send(pod, message)}),
      :after_op
    )
  end

  defp call(registry, module, "invoke", command, args) do
    args =
      case args do
        args when is_list(args) -> args
        args when is_nil(args) -> []
        args -> [args]
      end

    Logger.info("Invoke command in Pod")
    Logger.debug(%{module: module, command: command, args: args})

    payload = %{
      op: "invoke",
      id: UUIDv7.generate(),
      var: module.manifest().namespace(command),
      args:
        registry.encoder.encode!(
          args,
          module.manifest().format()
        )
    }

    message =
      payload
      |> registry.encoder.encode!("bencode")

    pod = get(registry, module)

    params = %{
      op: payload.op,
      id: payload.id,
      pod: pod,
      message: message,
      command: payload.var,
      args: args,
      result: %{}
    }

    registry.handler.event(params, :before_op)

    registry.handler.event(
      Map.merge(params, %{result: registry.manager.send(pod, message)}),
      :after_op
    )
  end

  # MARK: Public Calls

  @doc """
    Returns a map with the module and manifest
  """
  @spec setup(module :: module(), manifest :: module()) :: %{module: module(), manifest: module()}
  def setup(module, manifest),
    do: %{
      module: module,
      manifest: manifest
    }

  @doc """
    Calls the `describe` operand from a pod
  """
  def describe(registry, module) do
    call(registry, module, "describe")
    registry
  end

  @doc """
    Calls the `shutdown` operand from a pod
  """
  def shutdown(registry, module) do
    call(registry, module, "shutdown")
    registry
  end

  @doc """
    Calls the `invoke` operand from a pod
  """
  def invoke(registry, module, command, args \\ []) do
    call(registry, module, "invoke", command, args)
    registry
  end

  @doc """
  Stops all the pods inside the registry
  """
  def stop(registry, :all) do
    Logger.info("Stopping all pods")
    Enum.map(registry.pods, fn {_key, pod} -> stop(registry, pod) end)
  end

  def stop(registry, %{module: module, manifest: _, pid: pid} = pod) do
    %{pod: module, pid: pid, stop: registry.manager.stop(pod)}
  end
end
