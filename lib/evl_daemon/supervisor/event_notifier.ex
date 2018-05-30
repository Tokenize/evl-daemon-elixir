defmodule EvlDaemon.Supervisor.EventNotifier do
  use Supervisor
  alias EvlDaemon.{EventNotifier, StorageEngine, Task}

  def start_link(_opts) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    child_processes =
      for [notifier | opts] <- active_notifiers() ++ active_storage_engines() ++ active_tasks() do
        {notifier, opts}
      end

    Supervisor.init(child_processes, strategy: :one_for_one)
  end

  defp active_notifiers do
    for notifier <- Application.get_env(:evl_daemon, :event_notifiers) do
      case Keyword.get(notifier, :type) do
        "console" -> [EventNotifier.Console]
        "email" -> [EventNotifier.Email, List.flatten(Keyword.delete(notifier, :type))]
        "sms" -> [EventNotifier.SMS, List.flatten(Keyword.delete(notifier, :type))]
      end
    end
  end

  defp active_storage_engines do
    for storage_engine <- Application.get_env(:evl_daemon, :storage_engines) do
      case Keyword.get(storage_engine, :type) do
        "memory" ->
          [StorageEngine.Memory, List.flatten(Keyword.delete(storage_engine, :type))]

        _ ->
          nil
      end
    end
    |> Enum.reject(fn engine -> is_nil(engine) end)
  end

  defp active_tasks do
    for task <- Application.get_env(:evl_daemon, :tasks) do
      case Keyword.get(task, :type) do
        "status_report" ->
          [Task.StatusReport, List.flatten(Keyword.delete(task, :type))]

        _ ->
          nil
      end
    end
    |> Enum.reject(fn task -> is_nil(task) end)
  end
end
