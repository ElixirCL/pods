defmodule PodsProcessManagerTest do
  use ExUnit.Case
  doctest PodsProcessManager

  test "greets the world" do
    assert PodsProcessManager.hello() == :world
  end
end
