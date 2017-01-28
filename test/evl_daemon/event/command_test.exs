defmodule EvlDaemon.Event.CommandTest do
  use ExUnit.Case
  doctest EvlDaemon.Event.Command

  test "should return a description for supported commands" do
    assert EvlDaemon.Event.Command.description("5051CB") == "Login Interaction"
  end

  test "should return raw command code for unsupported commands" do
    assert EvlDaemon.Event.Command.description("005foobar") == "005"
  end
end
