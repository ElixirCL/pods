defmodule Pods.Handler do
  @moduledoc """
  Defines the handlers for the Pod lifecycle events
  """
  @callback event(payload :: map(), event :: atom()) :: none()
  @callback success(payload :: map()) :: none()
  @callback error(payload :: map()) :: none()
  @callback exception(payload :: term()) :: none()

  defmacro __using__(_opts) do
    quote do
      @behaviour Pods.Handler
    end
  end
end
