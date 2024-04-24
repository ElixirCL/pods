defmodule Pods.MixProject do
  use Mix.Project

  def project do
    [
      app: :pods,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Pods.Application, []}
    ]
  end

  defp paths(_), do: ["lib", "pods"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # bencode
      {:bento, "~> 1.0"},
      # json
      {:jason, "~> 1.4"},
      {:erlexec, "~> 2.0"},
      {:uuidv7, "~> 0.2"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
