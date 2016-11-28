defmodule EvlDaemon.EventQueueTest do
  use ExUnit.Case
  doctest EvlDaemon.EventQueue

  setup do
    {:ok, event_queue} = EvlDaemon.EventQueue.start_link
    {:ok, event_queue: event_queue}
  end

  test "can successfully push values to", %{event_queue: event_queue} do
    status = EvlDaemon.EventQueue.push(event_queue, 1)
    assert status == :ok
  end

  test "can successfully pop values from", %{event_queue: event_queue} do
    EvlDaemon.EventQueue.push(event_queue, 1)
    value = EvlDaemon.EventQueue.pop(event_queue)
    assert value == 1
  end

  test "returns nil if poppin an empty queue", %{event_queue: event_queue} do
    assert EvlDaemon.EventQueue.pop(event_queue) == nil
  end
end
