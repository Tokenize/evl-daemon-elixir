defmodule EnvisaEx.EventQueueTest do
  use ExUnit.Case
  doctest EnvisaEx.EventQueue

  setup do
    {:ok, event_queue} = EnvisaEx.EventQueue.start_link
    {:ok, event_queue: event_queue}
  end

  test "can successfully push values to", %{event_queue: event_queue} do
    status = EnvisaEx.EventQueue.push(event_queue, 1)
    assert status == :ok
  end

  test "can successfully pop values from", %{event_queue: event_queue} do
    EnvisaEx.EventQueue.push(event_queue, 1)
    value = EnvisaEx.EventQueue.pop(event_queue)
    assert value == 1
  end
end
