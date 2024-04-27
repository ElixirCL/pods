defmodule Pods.ProcessManager do
  def start(), do: :exec.start()
  def send(pid, message), do: :exec.send(pid, message)

  def load(executable, decoder, stdout_handler, stderr_handler, opts \\ []) do

    temp_dir = System.tmp_dir!()
    temp_file_stdout = Path.join([temp_dir, Path.basename(executable) <> ".stdout"])

    # Some processes may write a lot of text, so we try to decode a cache
    # until it works and then send the data to the handler
    stdout_watcher = fn origin, pid, response ->
      File.write!(temp_file_stdout, response, [:append])
      case decoder.decode(String.trim(File.read!(temp_file_stdout)), :bencode) do
        {:ok, data} ->
          stdout_handler.(%{origin: origin, pid: pid, response: response, data: data})
          File.rm_rf!(temp_file_stdout)
        _ -> nil
      end
    end

    # errors may not be in bencode, so we send the raw response
    stderr_watcher = fn origin, pid, response ->
      stderr_handler.(%{origin: origin, pid: pid, response: response})
    end

    {:ok, _, pid} =
      :exec.run_link(
        executable,
        [
          :stdin,
          {:stdout, stdout_watcher},
          {:stderr, stderr_watcher},
          :monitor,
          # https://github.com/babashka/pods/?tab=readme-ov-file#environment
          {:env, [{"BABASHKA_POD", "1"}]}
        ] ++ opts
      )

    pid
  end
end
