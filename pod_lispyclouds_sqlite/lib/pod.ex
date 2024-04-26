defmodule Pod.LispyClouds.SQLite do
  alias __MODULE__.Manifest

  def manifest, do: Manifest

  # options when loading the pod with the process manager
  def opts, do: []

  def setup(),
    do: Pods.Core.setup(__MODULE__, Manifest)

  def describe(pods) do
    Pods.Core.describe(pods, __MODULE__)
    pods
  end

  def invoke(pods, command, args \\ []) do
    Pods.Core.invoke(pods, __MODULE__, command, args)
    pods
  end

  def execute!(pods, args \\ []) do
    invoke(pods, "execute!", args)
  end
end
