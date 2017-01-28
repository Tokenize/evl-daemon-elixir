defmodule EvlDaemon.Event.DataTest do
  use ExUnit.Case
  doctest EvlDaemon.Event.Data

  test "should return a blank for data-less commands" do
    assert EvlDaemon.Event.Data.description("50196") == ""
  end

  test "should return description for commands with data" do
    assert EvlDaemon.Event.Data.description("5051CB") == "Successful"
  end

  test "should return description with raw partition & zone" do
    assert EvlDaemon.Event.Data.description("60110025A") == "[Partition: 1, Zone: 002]"
  end

  test "should return description with raw zone" do
    assert EvlDaemon.Event.Data.description("6060022E") == "[Zone: 002]"
  end

  test "should return zone description based on zone number" do
    Application.put_env(:evl_daemon, :zones, %{"002" => "Front door"})
    assert EvlDaemon.Event.Data.description("6060022E") == "[Zone: #2 Front door]"
    Application.put_env(:evl_daemon, :zones, %{})
  end
end
