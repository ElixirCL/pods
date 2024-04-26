defmodule PodsExampleProjectTest do
  use ExUnit.Case
  doctest PodsExampleProject

  test "greets the world" do
    assert PodsExampleProject.hello() == :world
  end
end
