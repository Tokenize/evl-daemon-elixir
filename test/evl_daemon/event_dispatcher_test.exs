defmodule EvlDaemon.EventDispatcherTest do
  use ExUnit.Case
  doctest EvlDaemon.EventDispatcher

  setup do
    {:ok, event_dispatcher} = EvlDaemon.EventDispatcher.start_link
    {:ok, event_dispatcher: event_dispatcher}
  end

  test "can successfully enqueue events", %{event_dispatcher: event_dispatcher} do
    status = EvlDaemon.EventDispatcher.enqueue(event_dispatcher, 1)
    assert status == :ok
  end
end
