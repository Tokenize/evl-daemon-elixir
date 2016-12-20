defmodule EvlDaemon.EventNotifier.ConsoleTest do
  import ExUnit.CaptureLog
  use ExUnit.Case
  doctest EvlDaemon.EventNotifier.Console

  setup do
    {:ok, event_dispatcher} = EvlDaemon.EventDispatcher.start_link
    {:ok, _notifier} = EvlDaemon.EventNotifier.Console.start_link(event_dispatcher)

    {:ok, event_dispatcher: event_dispatcher}
  end

  test "successfully logs the event", %{event_dispatcher: event_dispatcher} do
    output = capture_log fn ->
      EvlDaemon.EventDispatcher.enqueue(event_dispatcher, "5051CB")
    end

    assert Regex.match?(~r/Elixir\.EvlDaemon\.EventNotifier\.Console: \[\d+\] 5051CB/, output)
  end
end
