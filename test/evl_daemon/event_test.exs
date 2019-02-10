defmodule EvlDaemon.EventTest do
  use ExUnit.Case, async: true
  doctest EvlDaemon.Event

  test "should return a new Event based on payload and timestamp" do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    system_error = EvlDaemon.Event.new("50297", timestamp)

    assert system_error.command == "502"
    assert system_error.data == ""
    assert system_error.description.command == "System Error"
    assert system_error.priority == :critical
  end
end
