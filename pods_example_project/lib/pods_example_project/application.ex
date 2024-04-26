defmodule PodsExampleProject.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: PodsExampleProject.Worker.start_link(arg)
      # {PodsExampleProject.Worker, arg}
    ]

    Pods.Core.start(
      # Available Pods List
      [Pod.LispyClouds.SQLite],
      # Pod Manager
      Pods.ProcessManager,
      # Message Encoder
      PodsExampleProject.Encoder,
      # Message Decoder
      PodsExampleProject.Decoder,
      # stdout and stderr handler
      PodsExampleProject.Handler
    )
    |> Pod.LispyClouds.SQLite.execute!("create table if not exists foo ( int foo )")
    |> Pod.LispyClouds.SQLite.execute!("delete from foo")
    |> Pod.LispyClouds.SQLite.execute!("insert into foo values (1), (2)")
    |> Pod.LispyClouds.SQLite.execute!("select * from foo")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PodsExampleProject.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
