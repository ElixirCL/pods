defmodule Pods.Encoder do
  @moduledoc """
  Encodes messages to send to the pod process
  """
  @callback encode!(message :: term(), encoding :: String.t()) :: String.t()
  @callback encode(message :: term(), encoding :: String.t()) :: {:ok | :error, String.t()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Pods.Encoder
    end
  end
end
