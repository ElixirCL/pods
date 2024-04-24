defmodule Pods.LispyClouds.SQLite do
  @namespace "pod-lispyclouds-sqlite"

  require Logger

  def start(callback \\ nil, opts \\ []) do
    Pods.load(
      "#{@namespace}.py",
      callback ||
        fn _origin, _pid, response ->
          Map.merge(response, case Map.get(response, "value") do
            nil -> %{}
            value -> %{result: Jason.decode!(value)}
          end)
          |> IO.inspect()
        end,
      opts
    )
  end

  def describe(pods) do
    Logger.info("describe")
    Pods.call(pods, @namespace, "describe")
    |> IO.inspect()
    pods
  end

  def invoke(pods, command, args \\ []) do
    Logger.info(command)
    Logger.debug(args)
    Pods.call(pods, @namespace, "invoke", command, args)
    |> IO.inspect()
    pods
  end

  def execute!(pods, args \\ []) do
    invoke(pods, "execute!", args)
  end
end
