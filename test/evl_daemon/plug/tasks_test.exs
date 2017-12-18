defmodule EvlDaemon.Plug.TasksTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest EvlDaemon.Plug.Tasks

  @opts EvlDaemon.Router.init([])
  @task_opts %{"type" => "silent_arm", "zones" => ["001", "003"]}

  setup do
    EvlDaemon.StorageEngine.Memory.start_link([])

    Application.put_env(:evl_daemon, :auth_token, "test_token")

    on_exit fn ->
      pid = GenServer.whereis(EvlDaemon.Supervisor.Task)

      for child <- Supervisor.which_children(pid) do
        {_id, child_pid, _child_type, _child_module} = child

        Supervisor.terminate_child(pid, child_pid)
      end
    end

    :ok
  end

  describe "task creation" do
    test "returns 422 when attempting to create an invalid task" do
      conn = conn(:post, "/tasks?auth_token=test_token", Poison.encode!(%{"type" => "foobar"}))
             |> put_req_header("content-type", "application/json")
             |> EvlDaemon.Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 422
    end

    test "returns 201 when attempting to create a valid task" do
      conn = conn(:post, "/tasks?auth_token=test_token", Poison.encode!(@task_opts))
             |> put_req_header("content-type", "application/json")
             |> EvlDaemon.Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 201
    end

    test "returns 422 when attempting to create a valid task that already exists" do
      pid = GenServer.whereis(EvlDaemon.Supervisor.Task)
      Supervisor.start_child(pid, (@task_opts |> Map.delete("type") |> Map.to_list))

      conn = conn(:post, "/tasks?auth_token=test_token", Poison.encode!(@task_opts))
             |> put_req_header("content-type", "application/json")
             |> EvlDaemon.Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 422
    end
  end

  describe "task deletion" do
    test "returns 422 when attempting to delete an invalid task" do
      conn = conn(:delete, "/tasks?auth_token=test_token", Poison.encode!(%{"type" => "foobar"}))
             |> put_req_header("content-type", "application/json")
             |> EvlDaemon.Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 422
    end

    test "returns 422 when attempting to delete a non-running valid task" do
      conn = conn(:delete, "/tasks?auth_token=test_token", Poison.encode!(@task_opts))
             |> put_req_header("content-type", "application/json")
             |> EvlDaemon.Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 422
    end

    test "returns 200 when attempting to delete a running valid task" do
      pid = GenServer.whereis(EvlDaemon.Supervisor.Task)
      Supervisor.start_child(pid, (@task_opts |> Map.delete("type") |> Map.to_list))

      conn = conn(:delete, "/tasks?auth_token=test_token", Poison.encode!(@task_opts))
             |> put_req_header("content-type", "application/json")
             |> EvlDaemon.Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200
    end
  end
end
