defmodule Pods do
  defp md5(string) do
    :crypto.hash(:md5, string)
    |> Base.encode16(case: :lower)
  end

  def get(pods, namespace) do
    Map.get(pods, String.to_existing_atom(md5(namespace)))
  end

  def load(module, namespace, prefix, script, callback, opts \\ []) do
    path = Path.expand(Path.join([".", "pods", namespace, script]))

    {:ok, _, pid} =
      :exec.run_link(
        path,
        [
          :stdin,
          {:stderr, :stdout},
          {:stdout,
           fn origin, pid, response ->
             decoded_response = Bento.decode!(response)

             result =
               case Map.get(decoded_response, "value") do
                 nil -> []
                 value -> Jason.decode!(value)
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
               module: module,
               namespace: namespace,
               prefix: prefix,
               script: script,
               id: id,
               origin: origin,
               pid: pid,
               body: result,
               status: status,
               response: decoded_response
             }

             callback.(final_response)
           end},
          :monitor
        ] ++ opts
      )

    %{
      "#{md5(namespace)}": %{
        module: module,
        namespace: namespace,
        prefix: prefix,
        script: script,
        path: path,
        pid: pid
      }
    }
  end

  def start(pods) do
    :exec.start()

    pods
    |> Enum.reduce(%{}, fn pod, acc ->
      registry = Map.merge(acc, pod)

      # Call describe as the first input/output message
      for {_k, value} <- pod do
        value.module.describe(registry)
      end

      registry
    end)
  end

  def send_to_pod(pod, message) do
    %{pod: pod, message: message, response: :exec.send(pod.pid, Bento.encode!(message))}
  end

  def call(pods, namespace, "describe") do
    pod = get(pods, namespace)

    message =
      %{
        op: "describe",
        id: UUIDv7.generate()
      }

    send_to_pod(pod, message)
  end

  def call(pods, namespace, "invoke", command, args \\ []) do
    pod = get(pods, namespace)

    var = "#{pod.prefix}/#{command}"

    message =
      %{
        op: "invoke",
        id: UUIDv7.generate(),
        var: var,
        args:
          Jason.encode!(
            case args do
              args when is_list(args) -> args
              args when is_nil(args) -> []
              args -> [args]
            end
          )
      }

    send_to_pod(pod, message)
  end
end
