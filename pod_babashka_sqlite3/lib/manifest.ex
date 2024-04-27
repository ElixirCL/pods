defmodule Pod.Babashka.SQLite3.Manifest do
  @moduledoc """
  Stores the information for the pod
  """

  def version, do: "0.1.0"

  @doc """
    Returns the namespace that will be used when invoking the commands
    Example: pod.babashka.go-sqlite3/execute!
  """
  def namespace, do: "pod.babashka.go-sqlite3"

  @doc """
  Which format will the payload be encoded/decoded:
  - json
  - transit+json
  """
  def format, do: "transit+json"

  @doc """
  Which programming language this pod is implemented
  """
  def language, do: "golang"

  defp directory(), do: Path.join([
    "pods",
    "repository",
    "org.babashka",
    "go-sqlite3",
    version(),
  ])

  @doc """
    The executable artifact that will be returned
    depending on the requested os and arch params.
    values are from :os.type() and :erlang.system_info(:system_architecture)
    You can add other os and archs executables if needed.
  """
  def executable(%{type: _type, os: :darwin, arch: "x86_64" <> _arch}),
    do:
      Path.expand(
        Path.join([directory(), "mac_os_x", "x86_64", "pod-babashka-go-sqlite3"])
      )
end
