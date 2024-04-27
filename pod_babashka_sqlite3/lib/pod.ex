defmodule Pod.Babashka.SQLite3 do

  alias __MODULE__.Manifest

  def db(name \\ "testdb"), do: "#{name}.db"

  def babashka() do
    {type, _} = :os.type()
    exe = case type do
      :unix -> {"which", ["bb"]}
      _ -> {"where", ["bb.exe"]}
    end

    {command, args} = exe
    {bin, _} = System.cmd(command, args)
    {version, _} = System.cmd(String.trim(bin), ["--version"])

    case version do
      "babashka v" <> number -> {:ok, {String.trim(bin), String.trim(number)}}
      _ -> {:error, "babashka runtime not found"}
    end
  end

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

  def execute!(pods, db, args \\ []) do
    invoke(pods, "execute!", [db, args])
  end

  def query(pods, db, args \\ []) do
    invoke(pods, "query", [db, args])
  end

end
