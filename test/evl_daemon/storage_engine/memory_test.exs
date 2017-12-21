defmodule EvlDaemon.StorageEngine.MemoryTest do
  use ExUnit.Case, async: false
  doctest EvlDaemon.StorageEngine.Memory

  setup do
    {:ok, _pid} = EvlDaemon.StorageEngine.Memory.start_link([maximum_events: "5"])

    :ok
  end

  test "successfully stores the dispatched events" do
    assert (EvlDaemon.StorageEngine.Memory.all |> length) == 0
    EvlDaemon.EventDispatcher.enqueue("60111F9")
    EvlDaemon.EventDispatcher.enqueue("5051CB")

    :timer.sleep 1

    assert length(EvlDaemon.StorageEngine.Memory.all) == 2
  end

  test "honours the maximum_events limit" do
    Enum.each(1..6, fn (number) -> EvlDaemon.EventDispatcher.enqueue(number |> to_string) end)

    :timer.sleep 1

    assert length(EvlDaemon.StorageEngine.Memory.all) == 5
  end

  test "replaces old events once maximum_events is reached" do
    Enum.each(1..6, fn (number) -> EvlDaemon.EventDispatcher.enqueue(number |> to_string) end)

    :timer.sleep 1

    events = EvlDaemon.StorageEngine.Memory.all

    assert List.first(events).command == "2"
    assert List.last(events).command == "6"
  end

  test "returns oldest events first (by default)" do
    Enum.each(1..5, fn (number) -> EvlDaemon.EventDispatcher.enqueue(number |> to_string) end)

    :timer.sleep 1

    events = EvlDaemon.StorageEngine.Memory.all

    assert List.first(events).command == "1"
    assert List.last(events).command == "5"
  end

  test "returns newest events first (if requested)" do
    Enum.each(1..5, fn (number) -> EvlDaemon.EventDispatcher.enqueue(number |> to_string) end)

    :timer.sleep 1

    events = EvlDaemon.StorageEngine.Memory.all([order: :desc])

    assert List.first(events).command == "5"
    assert List.last(events).command == "1"
  end
end
