defmodule Pods.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Example
    Pods.start([Pods.LispyClouds.SQLite.start()])
    |> Pods.LispyClouds.SQLite.describe()
    |> Pods.LispyClouds.SQLite.execute!("create table if not exists foo ( int foo )")
    |> Pods.LispyClouds.SQLite.execute!("delete from foo")
    |> Pods.LispyClouds.SQLite.execute!("insert into foo values (1), (2)")
    |> Pods.LispyClouds.SQLite.execute!("select * from foo")

    children =
      [
        # Starts a worker by calling: Pods.Worker.start_link(arg)
        # {Pods.Worker, arg}
      ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pods.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
