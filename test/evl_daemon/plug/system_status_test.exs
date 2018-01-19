defmodule EvlDaemon.Plug.SystemStatusTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest EvlDaemon.Plug.SystemStatus

  @opts EvlDaemon.Router.init([])

  setup do
    Application.put_env(:evl_daemon, :auth_token, "test_token")

    :ok
  end

  test "returns 401 when accessing system status endpoint without auth_token" do
    conn =
      conn(:get, "/system_status")
      |> EvlDaemon.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "returns 401 when accessing system status endpoint with invalid auth_token" do
    conn =
      conn(:get, "/system_status?auth_token=invalid")
      |> EvlDaemon.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "returns 200 & system status with valid auth_token" do
    conn =
      conn(:get, "/system_status?auth_token=test_token")
      |> EvlDaemon.Router.call(@opts)

    decoded_response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    assert Map.has_key?(decoded_response, "event_notifiers")
    assert Map.has_key?(decoded_response, "storage_engines")
    assert Map.has_key?(decoded_response, "connection")
    assert Map.has_key?(decoded_response, "node_uptime")
  end
end
