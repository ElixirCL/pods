defmodule Mix.Tasks.Pod.Babashka.Sqlite3.Install do
  @moduledoc """
    Provides helper commands to install Sqlite3 pod
  """

  use Mix.Task

  @shortdoc """
    Installs the sqlite3 pod in pods directory
  """
  def run(_) do
    {:ok, {exe, _}} = Pod.Babashka.SQLite3.babashka()
    artifact = Path.expand(
      Path.join([
        Path.dirname(__ENV__.file),
        "..",
        "..",
        "..",
        "artifacts",
        "pod.edn"
      ])
    )

    project_pods_directory = Path.expand(Path.join(["pods"]))
    File.mkdir_p!(project_pods_directory)

    # Check https://github.com/babashka/pods/
    # Will install for the current system only
    # If you want other artifacts set env
    # Other env BABASHKA_PODS_OS_NAME=Linux
    # BASHKA_PODS_OS_ARCH=aarch64

    System.cmd(exe, [artifact], env: [{"BABASHKA_PODS_DIR", project_pods_directory}])
  end
end
