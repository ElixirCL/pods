defmodule Pods.Decoder do
  @moduledoc """
  Decodes messages from the pod process
  """
  @callback decode!(message :: term(), encoding :: String.t()) :: term()
  @callback decode(message :: term(), encoding :: String.t()) :: {:ok | :error, term()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Pods.Decoder
    end
  end
end
