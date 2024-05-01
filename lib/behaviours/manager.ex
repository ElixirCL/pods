defmodule Pods.Manager do
  @moduledoc """
  This is the process manager. Implements how the pods will be started on the operating system and provides the main stdio interface for pod communication.
  """
  @callback init() :: none()
  @callback send(pod :: map(), message :: String.t()) :: term()
  @callback stop(pod :: map()) :: term()
  @callback start(
              executable :: String.t(),
              decoder :: term(),
              out_handler :: function(),
              exception_handler :: function(),
              opts :: [String.t()]
            ) :: {:ok | :error, pos_integer() | term()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Pods.Manager
    end
  end
end
