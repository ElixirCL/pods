defmodule PodsExampleProject.Decoder do

  def decode(content, :bencode) do
    Bento.decode(content)
  end

  def decode!(content, :bencode) do
    Bento.decode!(content)
  end

  def decode!(content, "json") do
    Jason.decode!(content)
  end

  def decode!(content, "transit+json") do
    :transit.read(content, %{format: :json_verbose})
  end
end
