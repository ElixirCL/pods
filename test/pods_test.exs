defmodule PodsTest do
  use ExUnit.Case
  doctest Pods

  test "greets the world" do
    assert Pods.hello() == :world
  end
end
