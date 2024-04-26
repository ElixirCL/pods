defmodule PodsCoreTest do
  use ExUnit.Case
  doctest PodsCore

  test "greets the world" do
    assert PodsCore.hello() == :world
  end
end
