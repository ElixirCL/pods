defmodule PodsExampleProject.Handler do
  def on_pod_ready(pod, message) do
    IO.inspect([pod, message], label: :on_pod_ready)
  end

  def on_before_call(_registry, _pod, message, _op) do
    IO.inspect(message, label: :on_before_call)
  end

  def out(response) do
    IO.inspect(response, label: :out)
  end

  def error(response) do
    IO.inspect(response, label: :error)
  end
end
