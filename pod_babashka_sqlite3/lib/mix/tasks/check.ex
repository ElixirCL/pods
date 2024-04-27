defmodule Mix.Tasks.Pod.Babashka.Sqlite3.Check do
  @moduledoc """
    Provides helper commands to check SQLite3 pod
  """

  use Mix.Task

  @shortdoc """
    Checks if babashka runtime is on the $PATH
  """
  def run(_) do
    Pod.Babashka.SQLite3.babashka()
    |> IO.inspect()
  end
end
