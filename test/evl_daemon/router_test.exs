defmodule EvlDaemon.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest EvlDaemon.Router

  @opts EvlDaemon.Router.init([])

  setup do
    EvlDaemon.StorageEngine.Memory.start_link([])

    Application.put_env(:evl_daemon, :auth_token, "test_token")

    :ok
  end

  test "returns 401 if no auth_token is passed" do
    conn = conn(:get, "/events", "")
            |> EvlDaemon.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "returns 401 if invalid auth_token is passed" do
    conn = conn(:get, "/events?auth_token=invalid")
            |> EvlDaemon.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "returns 404 when accessing an invalid endpoint" do
    Application.put_env(:evl_daemon, :auth_token, "secret")

    conn = conn(:get, "/invalid_endpoint?auth_token=test_token")
            |> EvlDaemon.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "returns 200 when accessing valid endpoint with valid auth_token" do
    conn = conn(:get, "/events?auth_token=test_token")
            |> EvlDaemon.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[]"
  end
end
