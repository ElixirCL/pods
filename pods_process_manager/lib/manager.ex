defmodule Pods.ProcessManager do
  def start(), do: :exec.start()
  def send(pid, message), do: :exec.send(pid, message)

  def load(executable, stdout_handler, stderr_handler, opts \\ []) do
    {:ok, _, pid} =
      :exec.run_link(
        executable,
        [
          :stdin,
          :monitor,
          {:stderr,
           fn origin, pid, response ->
             stderr_handler.(%{origin: origin, pid: pid, response: response})
           end},
          {:stdout,
           fn origin, pid, response ->
             stdout_handler.(%{origin: origin, pid: pid, response: response})
           end}
        ] ++ opts
      )

    pid
  end
end
