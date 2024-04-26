defmodule PodsExampleProject.Handler do
  def on_pod_ready(pod, message) do
    IO.inspect([pod, message], label: :on_pod_ready)
  end

  def on_before_call(_registry, pod, message, op) do
    IO.inspect(pod.pid, label: op)
    IO.inspect(message, label: :on_before_call)
  end

  def out(response) do
    IO.inspect(response, label: :out)
  end

  def error(response) do
    IO.inspect(response, label: :error)
  end
end
