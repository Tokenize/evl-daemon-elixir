defmodule EvlDaemon.EventNotifier.HeartbeatTest do
  use ExUnit.Case, async: true
  doctest EvlDaemon.Task.Heartbeat

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass, host: "http://localhost:#{bypass.port}"}
  end

  test "fails if host is missing" do
    Process.flag(:trap_exit, true)
    opts = [auth_token: "foo", device: "123"]

    {status, reason} = EvlDaemon.Task.Heartbeat.start_link(opts)

    assert status == :error
    assert reason == "invalid options"
  end

  test "fails if auth_token is missing" do
    Process.flag(:trap_exit, true)
    opts = [host: "http://localhost", device: "123"]

    {status, reason} = EvlDaemon.Task.Heartbeat.start_link(opts)

    assert status == :error
    assert reason == "invalid options"
  end

  test "fails if device is missing" do
    Process.flag(:trap_exit, true)
    opts = [auth_token: "foo", host: "http://localhost"]

    {status, reason} = EvlDaemon.Task.Heartbeat.start_link(opts)

    assert status == :error
    assert reason == "invalid options"
  end

  test "starts if all arguments are present", %{bypass: bypass, host: host} do
    opts = [auth_token: "foo", host: host, device: "123"]

    Bypass.stub(bypass, "PUT", "/api/devices/123", fn conn ->
      Plug.Conn.resp(conn, 202, "{}")
    end)

    {status, pid} = EvlDaemon.Task.Heartbeat.start_link(opts)

    assert status == :ok
    assert Process.alive?(pid)
  end

  test "sends heartbeat after initialization", %{bypass: bypass, host: host} do
    opts = [auth_token: "foo", host: host, device: "123", interval: 10_000]

    Bypass.expect_once(bypass, "PUT", "/api/devices/123", fn conn ->
      Plug.Conn.resp(conn, 202, "{}")
    end)

    {:ok, _pid} = EvlDaemon.Task.Heartbeat.start_link(opts)
    EvlDaemon.Task.Heartbeat.latest_sent_at()
  end

  test "returns timestamp of latest heartbeat", %{bypass: bypass, host: host} do
    opts = [auth_token: "foo", host: host, device: "123", interval: 10_000]

    Bypass.stub(bypass, "PUT", "/api/devices/123", fn conn ->
      Plug.Conn.resp(conn, 202, "{}")
    end)

    {:ok, _pid} = EvlDaemon.Task.Heartbeat.start_link(opts)
    latest_heartbeat = EvlDaemon.Task.Heartbeat.latest_sent_at()

    assert Time.diff(latest_heartbeat, Time.utc_now()) <= 1
  end
end
