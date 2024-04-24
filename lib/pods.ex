defmodule Pods do
  defp md5(string) do
    :crypto.hash(:md5, string)
    |> Base.encode16(case: :lower)
  end

  def get(pods, namespace) do
    Map.get(pods, String.to_existing_atom(md5(namespace)))
  end

  def load(name, callback, opts \\ []) do
    dirname =
      name
      |> String.replace(Path.extname(name), "")

    path = Path.expand(Path.join([".", "pods", dirname, name]))

    {:ok, _, pid} =
      :exec.run_link(
        path,
        [
          :stdin,
          {:stderr, :stdout},
          {:stdout,
           fn origin, pid, response ->
             callback.(origin, pid, Bento.decode!(response))
           end},
          :monitor
        ] ++ opts
      )

    %{
      "#{md5(dirname)}": %{
        namespace: dirname,
        script: name,
        path: path,
        pid: pid
      }
    }
  end

  def start(pods) do
    :exec.start()

    pods
    |> Enum.reduce(%{}, fn pod, acc -> Map.merge(acc, pod) end)
  end

  def send_to_pod(pid, message) do
    %{pid: pid, message: message, response: :exec.send(pid, Bento.encode!(message))}
  end

  def call(pods, namespace, "describe") do
    pod = get(pods, namespace)

    message =
      %{
        op: "describe",
        id: UUIDv7.generate()
      }

    send_to_pod(pod.pid, message)
  end

  def call(pods, namespace, "invoke", command, args \\ []) do
    pod = get(pods, namespace)
    var = "#{String.replace(namespace, "-", ".")}/#{command}"

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

    send_to_pod(pod.pid, message)
  end
end
