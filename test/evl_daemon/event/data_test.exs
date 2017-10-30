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

  test "should return partition description based on partition number" do
    Application.put_env(:evl_daemon, :partitions, %{"2" => "Basement"})
    assert EvlDaemon.Event.Data.description("6502CD") == "[Partition: #2 Basement]"
    Application.put_env(:evl_daemon, :partitions, %{})
  end

  test "should return Keypad LED state" do
    assert EvlDaemon.Event.Data.description("51081FF") == "[Ready LED, Backlight LED]"
  end

  test "should return 'Partition Armed' number & mode" do
    assert EvlDaemon.Event.Data.description("65211FF") == "[Partition: 1, Mode: Stay]"
  end

  test "should return correct Verbose Trouble Status" do
    assert EvlDaemon.Event.Data.description("849080D") == "[Failure to Communicate]"
  end

  test "should return partition for partition commands" do
    assert EvlDaemon.Event.Data.partition("6502CD") == "2"
  end

  test "should return partition for partition-zone commands" do
    assert EvlDaemon.Event.Data.partition("60130045E") == "3"
  end

  test "should return nil partition for partition-less commands" do
    assert EvlDaemon.Event.Data.partition("620000058") == nil
  end

  test "should return zone for zone commands" do
    assert EvlDaemon.Event.Data.zone("60900332") == "003"
  end

  test "should return zone for partition-zone commands" do
    assert EvlDaemon.Event.Data.zone("60130045E") == "004"
  end

  test "should return nil zone for zone-less commands" do
    assert EvlDaemon.Event.Data.zone("620000058") == nil
  end
end
