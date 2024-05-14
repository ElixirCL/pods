defmodule Pods.Test.Decoder do
  use Pods.Decoder
  def decode(message, "bencode"), do: Bento.decode(message)
  def decode(message, "json"), do: Jason.decode(message)
  def decode!(message, "bencode"), do: Bento.decode!(message)
  def decode!(message, "json"), do: Jason.decode!(message)
end

defmodule Pods.Test.Encoder do
  use Pods.Encoder
  def encode(message, "bencode"), do: Bento.encode(message)
  def encode(message, "json"), do: Jason.encode(message)
  def encode!(message, "bencode"), do: Bento.encode!(message)
  def encode!(message, "json"), do: Jason.encode!(message)
end

defmodule Pods.Test.Handler do
  alias Bento.Metainfo
  require Logger

  use Pods.Handler

  def event(payload, type) do
    Logger.info("Got Pod Event #{type}")
    Logger.debug(payload)
  end

  def success(payload) do
    Logger.info("Got Pod Success Response")
    Logger.debug(payload)
    :ets.insert(:pods, {payload.raw.pid, {:ok, payload}})
  end

  def error(payload) do
    Logger.info("Got Pod Error Response")
    Logger.debug(payload)
    :ets.insert(:pods, {payload.raw.pid, {:error, payload}})
  end

  def exception(payload) do
    Logger.info("Got Pod Message")
    Logger.debug(payload)
    :ets.insert(:pods, {payload.raw.pid, {:message, payload}})
  end
end

defmodule Pods.Test.Manager do
  require Logger
  use Pods.Manager

  def init() do
    Logger.info("Manager started")
    :ets.new(:pods, [:bag, :public, :named_table])
    :exec.start()
  end

  def stop(pod) do
    Logger.info("Stopping Pod #{pod.module}")
    :exec.stop(pod.pid)
  end

  def send(pod, message) do
    Logger.info("Sending Message to Pod #{pod.module}")
    :exec.send(pod.pid, message)
  end

  def start(executable, _decoder, out_handler, exception_handler, opts \\ []) do
    # exceptions may not be in bencode, so we send the raw response
    stderr_watcher = fn origin, pid, response ->
      exception_handler.(%{origin: origin, pid: pid, response: response})
    end

    # Some processes may write a lot of text (streams)
    stdout_watcher = fn origin, pid, response ->
      out_handler.(%{origin: origin, pid: pid, response: response})
    end

    # start the process with ELIXIR_POD in the env
    case :exec.run_link(
           executable,
           [
             :stdin,
             {:stdout, stdout_watcher},
             {:stderr, stderr_watcher},
             :monitor,
             {:env, [{"ELIXIR_POD", "1"}]}
           ] ++ opts
         ) do
      {:ok, _, pid} -> {:ok, pid}
      _ = error -> {:error, error}
    end
  end
end

defmodule Pod.Test.SQLite do
  use Pods.Pod

  def execute!(pods, args \\ []) do
    invoke(pods, "execute!", args)
  end
end

defmodule Pod.Test.SQLite.Manifest do
  use Pods.Manifest

  @name "pod.lispyclouds.sqlite"

  def description(),
    do: %{
      name: @name,
      about: "A simple SQLite3 client made with Python",
      version: "1.0.0",
      language: language(),
      opts: opts(),
      format: format()
    }

  def namespace(command), do: namespace(@name, command)
  def opts, do: []
  def format, do: "json"
  def language, do: "python"

  def executable(%{type: _type, os: _os, arch: _arch}),
    do:
      Path.expand(
        Path.join([
          Path.dirname(__ENV__.file),
          "..",
          "example",
          "artifacts",
          "main.py"
        ])
      )
end

defmodule PodsTest do
  use ExUnit.Case

  require Logger

  alias Pods.Test.Decoder
  alias Pods.Test.Encoder
  alias Pods.Test.Handler
  alias Pods.Test.Manager
  alias Pod.Test.SQLite, as: SQLitePod

  doctest Pods

  test "test that interacts correctly with stdin and stdout" do
    pods =
      Pods.start(
        # Available Pods List
        [SQLitePod],
        # Pod Manager
        Manager,
        # Message Encoder
        Encoder,
        # Message Decoder
        Decoder,
        # stdout and stderr handler
        Handler
      )

    pods
    |> SQLitePod.execute!("create table if not exists foo ( int foo )")
    |> SQLitePod.execute!("delete from foo")
    |> SQLitePod.execute!("insert into foo values (1), (2)")
    |> SQLitePod.execute!("select * from foo")
    |> then(fn pods ->
      # Give a little time to complete the operations
      receive do
      after
        50 ->
          pod = Map.get(pods.pods, SQLitePod)

          assert :ets.lookup(:pods, pod.pid)
                 |> Enum.filter(fn
                   {_pid, {:ok, %{result: [[1], [2]]}}} -> true
                   _ -> false
                 end)
                 |> Enum.count() >= 1

          Pods.stop(pods, :all)
      end
    end)
  end
end
