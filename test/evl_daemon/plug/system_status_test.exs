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

  test "returns status with valid auth_token" do
    conn =
      conn(:get, "/system_status?auth_token=test_token")
      |> EvlDaemon.Router.call(@opts)

    decoded_response = Poison.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    assert Map.has_key?(decoded_response, "notifiers")
    assert Map.has_key?(decoded_response, "storage")
    assert Map.has_key?(decoded_response, "connection")
    assert Map.has_key?(decoded_response, "uptime")
  end

  describe "armed states when query_status is false" do
    setup [:start_status_report_task]

    test "returns Armed-Away" do
      EvlDaemon.EventDispatcher.enqueue("65210FE")

      Process.sleep(100)

      conn =
        conn(:get, "/system_status?auth_token=test_token")
        |> EvlDaemon.Router.call(@opts)

      decoded_response = Poison.decode!(conn.resp_body)
      armed_state = Map.get(decoded_response, "armed_state")
      assert Map.get(armed_state, "1") == "Armed in Away mode."
    end

    test "returns Armed-Stay" do
      EvlDaemon.EventDispatcher.enqueue("65211FF")

      Process.sleep(100)

      conn =
        conn(:get, "/system_status?auth_token=test_token")
        |> EvlDaemon.Router.call(@opts)

      decoded_response = Poison.decode!(conn.resp_body)
      armed_state = Map.get(decoded_response, "armed_state")
      assert Map.get(armed_state, "1") == "Armed in Stay mode."
    end

    test "returns Zero-Entry-Away" do
      EvlDaemon.EventDispatcher.enqueue("6521200")
      EvlDaemon.EventDispatcher.enqueue("61000128")

      Process.sleep(100)

      conn =
        conn(:get, "/system_status?auth_token=test_token")
        |> EvlDaemon.Router.call(@opts)

      decoded_response = Poison.decode!(conn.resp_body)
      armed_state = Map.get(decoded_response, "armed_state")
      assert Map.get(armed_state, "1") == "Armed in Zero-Entry-Away mode."
    end

    test "returns Zero-Entry-Stay" do
      EvlDaemon.EventDispatcher.enqueue("6521301")
      EvlDaemon.EventDispatcher.enqueue("60900130")

      Process.sleep(100)

      conn =
        conn(:get, "/system_status?auth_token=test_token")
        |> EvlDaemon.Router.call(@opts)

      decoded_response = Poison.decode!(conn.resp_body)
      armed_state = Map.get(decoded_response, "armed_state")
      assert Map.get(armed_state, "1") == "Armed in Zero-Entry-Stay mode."
    end

    test "returns not armed if it gets a disarm event" do
      EvlDaemon.EventDispatcher.enqueue("6521301")
      EvlDaemon.EventDispatcher.enqueue("6551D1")
      EvlDaemon.EventDispatcher.enqueue("60900130")

      Process.sleep(100)

      conn =
        conn(:get, "/system_status?auth_token=test_token")
        |> EvlDaemon.Router.call(@opts)

      decoded_response = Poison.decode!(conn.resp_body)
      armed_state = Map.get(decoded_response, "armed_state")
      assert Map.get(armed_state, "1") == "Unarmed."
    end

    test "returns not armed if it gets a failed to arm event" do
      EvlDaemon.EventDispatcher.enqueue("6521301")
      EvlDaemon.EventDispatcher.enqueue("6591D5")
      EvlDaemon.EventDispatcher.enqueue("60900130")

      Process.sleep(100)

      conn =
        conn(:get, "/system_status?auth_token=test_token")
        |> EvlDaemon.Router.call(@opts)

      decoded_response = Poison.decode!(conn.resp_body)
      armed_state = Map.get(decoded_response, "armed_state")
      assert Map.get(armed_state, "1") == "Failed to arm."
    end
  end

  describe "armed states when query_status is true" do
  end

  # Private functions
  defp start_status_report_task(_context) do
    {:ok, pid} = start_supervised(EvlDaemon.Task.StatusReport)

    %{task_pid: pid}
  end
end
