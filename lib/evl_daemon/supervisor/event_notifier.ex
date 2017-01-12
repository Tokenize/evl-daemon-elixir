defmodule EvlDaemon.Supervisor.EventNotifier do
  use Supervisor

  def start_link(dispatcher_pid) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, dispatcher_pid)
  end

  def init(dispatcher_pid) do
    child_processes = for [notifier | opts] <- active_notifiers() do
      worker(notifier, [dispatcher_pid | opts])
    end

    supervise(child_processes, strategy: :one_for_one)
  end

  defp active_notifiers do
    for notifier <- Application.get_env(:evl_daemon, :event_notifiers) do
      case Keyword.get(notifier, :type) do
        "console" -> [EvlDaemon.EventNotifier.Console]
        "email" -> [EvlDaemon.EventNotifier.Email, List.flatten(Keyword.delete(notifier, :type))]
        "sms" -> [EvlDaemon.EventNotifier.SMS, List.flatten(Keyword.delete(notifier, :type))]
      end
    end
  end
end
