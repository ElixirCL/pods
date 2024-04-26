defmodule PodsExampleProject.Decoder do
  def decode!(content, :bencode) do
    Bento.decode!(content)
  end

  def decode!(content, "json") do
    Jason.decode!(content)
  end

  def decode(_content, "transit+json") do
    # not implemented yet
    :noop
  end
end
