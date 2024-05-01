defmodule Pod.LispyClouds.SQLite.Manifest do
  @moduledoc """
  Stores the information for the pod
  """

  use Pods.Manifest

  @name "pod.lispyclouds.sqlite"

  def description(), do: %{
    name: @name,
    about: "A simple SQLite3 client made with Python",
    version: "1.0.0",
    language: language(),
    opts: opts(),
    format: format()
  }

  @doc """
    Returns the namespace that will be used when invoking the commands
    Example: pod.lispyclouds.sqlite/execute!
  """
  def namespace(command), do: namespace(@name, command)

  # options when loading the pod with the process manager
  def opts, do: []

  @doc """
  Which format will the payload be encoded/decoded:
  - json
  """
  def format, do: "json"

  @doc """
  Which programming language this pod is implemented
  """
  def language, do: "python"

  @doc """
    The executable artifact that will be returned
    depending on the requested os and arch params.
    values are from :os.type() and :erlang.system_info(:system_architecture)
  """
  def executable(%{type: _type, os: _os, arch: _arch}),
    do:
      Path.expand(
        Path.join([
          Path.dirname(__ENV__.file),
          "..",
          "artifacts",
          "main.py"
        ])
      )
end
