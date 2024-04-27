defmodule Pods.Core do
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

  defp describe_message(),
    do: %{
      op: "describe",
      id: UUIDv7.generate()
    }

  # comply with the protocol. the first command when load is ready must be describe
  defp pod_is_ready(pod, pid, manager, encoder, handler) do
    message =
      describe_message()
      |> encoder.encode!(:bencode)

    handler.on_pod_ready(pod, message)
    manager.send(pid, message)
  end

  # helper function for setup a pod
  def setup(module, manifest),
    do: %{
      name: manifest.namespace(),
      module: module,
      manifest: manifest
    }

  def start(pod_modules, manager, encoder, decoder, handler) do
    manager.start()

    pods_with_pids =
      Enum.map(pod_modules, fn module ->
        pod = module.setup()

        decode_out = fn %{origin: origin, pid: pid, response: response} = raw ->

          decoded_response = decoder.decode!(response, :bencode)

          result =
            case Map.get(decoded_response, "value") do
              nil -> []
              value -> decoder.decode!(value, module.manifest().format())
            end

          status =
            case Map.get(decoded_response, "status") do
              nil ->
                :ok

              value ->
                case List.first(value) do
                  "done" -> :ok
                  _ -> :error
                end
            end

          id = Map.get(decoded_response, "id", pid)

          final_response = %{
            pod: pod,
            origin: origin,
            pid: pid,
            id: id,
            status: status,
            result: result,
            response: decoded_response,
            raw: raw
          }

          handler.out(final_response)
        end

        decode_error = fn %{origin: origin, pid: pid, response: response} = raw ->
          decoded_response = decoder.decode!(response, :bencode)

          final_response = %{
            pod: pod,
            origin: origin,
            pid: pid,
            response: decoded_response,
            raw: raw
          }

          handler.error(final_response)
        end

        pid = %{
          pid:
            manager.load(
              module.manifest().executable(os_type()),
              decoder,
              decode_out,
              decode_error,
              module.opts()
            )
        }

        item = %{
          "#{to_string(module)}": Map.merge(pod, pid)
        }

        pod_is_ready(Map.merge(pod, pid), pid.pid, manager, encoder, handler)

        item
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

  def call(registry, module, "describe") do
    message =
      describe_message()
      |> registry.encoder.encode!(:bencode)

    pod = get(registry, module)

    registry.handler.on_before_call(registry, pod, message, "describe")

    registry.manager.send(pod.pid, message)
  end

  def call(registry, module, "invoke", command, args \\ []) do
    var = "#{module.manifest().namespace}/#{command}"

    pod = get(registry, module)

    message =
      %{
        op: "invoke",
        id: UUIDv7.generate(),
        var: var,
        args:
          registry.encoder.encode!(
            case args do
              args when is_list(args) -> args
              args when is_nil(args) -> []
              args -> [args]
            end,
            module.manifest().format()
          )
      }
      |> registry.encoder.encode!(:bencode)

    registry.handler.on_before_call(registry, pod, message, "invoke")
    registry.manager.send(pod.pid, message)
  end

  def describe(registry, module) do
    call(registry, module, "describe")
  end

  def invoke(registry, module, command, args \\ []) do
    call(registry, module, "invoke", command, args)
  end
end
