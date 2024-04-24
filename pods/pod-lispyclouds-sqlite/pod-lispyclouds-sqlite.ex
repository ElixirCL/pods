defmodule Pods.LispyClouds.SQLite do
  # the directory of the pod
  @namespace "pod-lispyclouds-sqlite"

  # the script that will be run, must have execution permissions (655)
  @script "#{@namespace}.py"

  # the prefix for the commands that the script expects
  # example command: pod.lispyclouds.sqlite/execute!
  @prefix "pod.lispyclouds.sqlite"

  require Logger

  def start(callback \\ nil, opts \\ []) do
    Logger.info("Starting #{__MODULE__} Pod")

    Pods.load(
      __MODULE__,
      @namespace,
      @prefix,
      @script,
      callback ||
        fn response ->
          response
          |> IO.inspect()
        end,
      opts
    )
  end

  def describe(pods) do
    Logger.debug("describe")
    Pods.call(pods, @namespace, "describe")
    pods
  end

  def invoke(pods, command, args \\ []) do
    Logger.debug(command)
    Pods.call(pods, @namespace, "invoke", command, args)
    pods
  end

  def execute!(pods, args \\ []) do
    invoke(pods, "execute!", args)
  end
end
