defmodule Pods.Pod do
  @moduledoc """
  The main public api for the Pod process.
  """
  @callback manifest() :: module()
  @callback setup() :: %{module: module(), manifest: module()}

  @callback describe(pods :: map()) :: map()
  @callback invoke(pods :: map(), command :: String.t(), args :: term()) :: map()
  @callback shutdown(pods :: map()) :: map()

  defmacro __using__(_opts) do
    quote do
      @behaviour Pods.Pod

      @impl true
      def manifest(), do: __MODULE__.Manifest

      @impl true
      def setup(), do: Pods.setup(__MODULE__, manifest())

      @impl true
      def describe(pods) do
        Pods.describe(pods, __MODULE__)
      end

      @impl true
      def invoke(pods, command, args \\ []) do
        Pods.invoke(pods, __MODULE__, command, args)
      end

      @impl true
      def shutdown(pods) do
        Pods.shutdown(pods, __MODULE__)
      end
    end
  end
end
