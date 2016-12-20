defmodule EvlDaemon.EventTest do
  use ExUnit.Case
  doctest EvlDaemon.Event

  test "should return a description for supported commands" do
    assert EvlDaemon.Event.command_description("5051CB") == "Login Interaction"
  end

  test "should return raw command code for unsupported commands" do
    assert EvlDaemon.Event.command_description("005foobar") == "005"
  end

  test "should return a blank for data-less commands" do
    assert EvlDaemon.Event.data_description("50196") == ""
  end

  test "should return description for commands with data" do
    assert EvlDaemon.Event.data_description("5051CB") == "Successful"
  end

  test "should return a new Event based on payload and timestamp" do
    timestamp = DateTime.utc_now |> DateTime.to_unix
    system_error = EvlDaemon.Event.new("50297", timestamp)

    assert system_error.command == "502"
    assert system_error.data == ""
    assert system_error.description == "System Error"
    assert system_error.priority == :critical
  end
end
