defmodule EvlDaemon.Plug.Tasks do
  import Plug.Conn

  @tasks %{"silent_arm" => EvlDaemon.Task.SilentArm}
  @task_types (@tasks |> Map.keys)

  def init(options), do: options

  def call(%Plug.Conn{request_path: "/tasks", method: "POST", body_params: %{"type" => type} = params} = conn, _opts) when type in @task_types do
    task_opts = atomized_task_opts(params)
    {code, message} = do_create_task(task_opts, type)

    conn
    |> do_send_response(code, message)
  end

  def call(%Plug.Conn{request_path: "/tasks", method: "POST"} = conn, _opts) do
    conn
    |> do_send_unprocessable_entity_response
  end

  def call(%Plug.Conn{request_path: "/tasks", method: "DELETE", body_params: %{"type" => type} = params} = conn, _opts) when type in @task_types do
    task_opts = atomized_task_opts(params)
    {code, message} = do_terminate_task(task_opts, type)

    conn
    |> do_send_response(code, message)
  end

  def call(%Plug.Conn{request_path: "/tasks", method: "DELETE"} = conn, _opts) do
    conn
    |> do_send_unprocessable_entity_response
  end

  def call(conn, _opts), do: conn

  # Private functions

  def do_send_response(conn, code, payload) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(payload))
    |> halt
  end

  def do_send_unprocessable_entity_response(conn) do
    conn
    |> do_send_response(:unprocessable_entity, "Unsupported task type")
  end

  defp do_create_task(task_opts, task_type) do
    case do_create_task_process(task_opts, task_type) do
      {:ok, _pid} -> {:created, "Task [#{task_type}] created successfully."}
      {_, error} -> {:unprocessable_entity, error}
    end
  end

  defp do_create_task_process(opts, task_type) do
    pid = GenServer.whereis(EvlDaemon.Supervisor.Task)

    child = fetch_task_pid(task_type)

    case child do
      nil -> Supervisor.start_child(pid, opts)
      _ -> {:error, :already_started}
    end
  end

  defp do_terminate_task(task_opts, task_type) do
    case do_terminate_task_process(task_opts, task_type) do
      :ok -> {:ok, "Task [#{task_type}] deleted successfully."}
      {:error, error} -> {:unprocessable_entity, error}
    end
  end

  defp do_terminate_task_process(_opts, task_type) do
    pid = GenServer.whereis(EvlDaemon.Supervisor.Task)
    child = fetch_task_pid(task_type)

    case child do
      nil -> {:error, :not_found}
      child_pid -> Supervisor.terminate_child(pid, child_pid)
    end
  end

  def fetch_task_pid(task_type) do
    pid = GenServer.whereis(EvlDaemon.Supervisor.Task)

    child_information = Supervisor.which_children(pid) |> Enum.find(fn (child) ->
      {_id, _pid, _child_type, [child_module]} = child

      child_module == module_name_for_task_type(task_type)
    end)

    case child_information do
      {_id, child_pid, _type, _module} -> child_pid
      _ -> nil
    end
  end

  def module_name_for_task_type(type) do
    @tasks
    |> Map.get(type)
  end

  def atomized_task_opts(opts) do
    _ = :zones

    Map.delete(opts, "type")
    |> Enum.map(fn {key, value} -> {String.to_existing_atom(key), value} end)
    |> Enum.into([], fn {a, b} -> [{a, b}] end)
  end
end
