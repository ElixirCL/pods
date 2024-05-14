defmodule Pods.MixProject do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :pods,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
    ] ++ docs()
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Elixir Pods is a lightweight protocol on top of stdout and stderr."
  end

  defp docs do
    [
      # Docs
      name: "Elixir Pods",
      source_url: "https://github.com/ElixirCL/pods",
      homepage_url: "https://github.com/ElixirCL/pods",
      docs: [
        # The main page in the docs
        main: "examples",
        # logo: "https://raw.githubusercontent.com/ElixirCL/elixircl.github.io/main/assets/logo.png",
        extras: [
          "README.md",
          "LICENSE.md",
          "CHANGELOG.md",
          "EXAMPLES.livemd",
          "AUTHORS.md",
          "POD_PROTOCOL.md"
        ],
        authors: ["AUTHORS.md"],
        output: "docs"
      ]
    ]
  end

  defp package() do
    [
      name: "pods",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["ElixirCL"],
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => "https://github.com/ElixirCL/pods"}
      # Remove below comment to make the package private
      # organization: "elixircl_"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuidv7, "~> 0.2"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:bento, "~> 1.0", only: [:test]},
      {:erlexec, "~> 2.0", only: [:test]}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
