defmodule ClientCoreTest do
  use ExUnit.Case
  doctest ClientCore

  test "greets the world" do
    assert ClientCore.hello() == :world
  end
end
