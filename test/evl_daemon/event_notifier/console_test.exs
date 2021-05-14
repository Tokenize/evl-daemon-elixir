defmodule EvlDaemon.EventNotifier.ConsoleTest do
  import ExUnit.CaptureLog
  use ExUnit.Case, async: false
  doctest EvlDaemon.EventNotifier.Console

  setup do
    EvlDaemon.EventNotifier.Console.start_link()

    :ok
  end

  test "successfully logs the event" do
    output =
      capture_log(fn ->
        EvlDaemon.EventDispatcher.handle_cast({:enqueue, "5051CB", "1620960869"}, nil)
      end)

    assert Regex.match?(~r/Elixir\.EvlDaemon\.EventNotifier\.Console: \[\d+\] 505:1/, output)
  end
end
