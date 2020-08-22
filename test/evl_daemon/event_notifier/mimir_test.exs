defmodule EvlDaemon.EventNotifier.MimirTest do
  use ExUnit.Case, async: false
  doctest EvlDaemon.EventNotifier.Mimir

  setup do
    bypass = Bypass.open()

    {:ok, _pid} =
      EvlDaemon.EventNotifier.Mimir.start_link(
        auth_token: "foo",
        host: "http://localhost:#{bypass.port}",
        device: "123"
      )

    {:ok, bypass: bypass}
  end

  test "successfully notifies mimir of the event", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/api/events", fn conn ->
      Plug.Conn.resp(conn, 201, "{}")
    end)

    EvlDaemon.EventDispatcher.enqueue("60111F9")
    Process.sleep(500)
  end
end
