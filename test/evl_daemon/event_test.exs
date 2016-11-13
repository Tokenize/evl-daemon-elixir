defmodule EvlDaemon.EventTest do
  use ExUnit.Case
  doctest EvlDaemon.Event

  test "should return a description for supported commands" do
    assert EvlDaemon.Event.command_description("5051CB") == "Login Interaction"
  end

  test "should return raw command code for unsupported commands" do
    assert EvlDaemon.Event.command_description("005foobar") == "005"
  end

  test "should return 'containing no data' for data-less commands" do
    assert EvlDaemon.Event.data_description("50196") == "containing no data."
  end

  test "should return 'containing data of' for commands with data" do
    assert EvlDaemon.Event.data_description("5051CB") == "containing data of 1."
  end
end
