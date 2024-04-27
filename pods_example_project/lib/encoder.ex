defmodule PodsExampleProject.Encoder do
  def encode!(content, :bencode) do
    Bento.encode!(content)
  end

  def encode!(content, "json") do
    Jason.encode!(content)
  end

  def encode!(content, "transit+json") do
    :transit.write(content, %{format: :json_verbose})
  end
end
