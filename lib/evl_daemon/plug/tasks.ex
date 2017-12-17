defmodule EvlDaemon.Plug.Tasks do
  import Plug.Conn

  @tasks %{"silent_arm" => EvlDaemon.Task.SilentArm}
  @task_types (@tasks |> Map.keys)

  def init(options), do: options

  def call(%Plug.Conn{request_path: "/tasks", method: "POST", body_params: %{"type" => type} = params} = conn, _opts) when type in @task_types do
    {code, message} = do_create_task(params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(message))
    |> halt
  end

  def call(%Plug.Conn{request_path: "/tasks", method: "POST"} = conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unprocessable_entity, Poison.encode!("Unsupported task type."))
    |> halt
  end

  def call(%Plug.Conn{request_path: "/tasks", method: "DELETE", body_params: %{"type" => type} = params} = conn, _opts) when type in @task_types do
    {code, message} = do_terminate_task(params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(message))
    |> halt
  end

  def call(%Plug.Conn{request_path: "/tasks", method: "DELETE"} = conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unprocessable_entity, Poison.encode!("Unsupported task type."))
    |> halt
  end

  # Private functions

  defp do_create_task(opts) do
    task_type = opts["type"]
    task_opts = opts |> Map.delete("type") |> Map.to_list

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

  defp do_terminate_task(opts) do
    task_type = opts["type"]
    task_opts = opts |> Map.delete("type") |> Map.to_list

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
end
