defmodule Pods.Manifest do
  @moduledoc """
  Handles the meta data for running the pod process in the OS
  """
  @callback description() :: %{
              name: String.t(),
              about: String.t(),
              version: String.t(),
              language: String.t(),
              format: String.t(),
              opts: [String.t()]
            }

  @callback namespace(command :: String.t()) :: String.t()

  @callback format() :: String.t()

  @callback opts() :: [String.t()]

  @callback executable(os_info :: %{type: String.t(), os: String.t(), arch: String.t()}) ::
              String.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour Pods.Manifest

      def description(args),
        do:
          Map.merge(
            %{
              name: to_string(__MODULE__),
              about: "My Pod",
              version: "0.1.0",
              language: "elixir",
              format: format(),
              opts: opts()
            },
            args
          )

      def namespace(ns, command) do
        "#{ns}/#{command}"
      end
    end
  end
end
