defmodule Pod.LispyClouds.SQLite do
  use Pods.Pod

  def execute!(pods, args \\ []) do
    invoke(pods, "execute!", args)
  end
end
