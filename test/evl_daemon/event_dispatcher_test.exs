defmodule EvlDaemon.EventDispatcherTest do
  use ExUnit.Case, async: true
  doctest EvlDaemon.EventDispatcher

  test "can successfully enqueue events" do
    status = EvlDaemon.EventDispatcher.enqueue("1")
    assert status == :ok
  end
end
