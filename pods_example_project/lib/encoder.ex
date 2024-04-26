defmodule PodsExampleProject.Encoder do
  def encode!(content, :bencode) do
    Bento.encode!(content)
  end

  def encode!(content, "json") do
    Jason.encode!(content)
  end

  def encode(_content, "transit+json") do
    # not implemented yet
    :noop
  end
end
