defmodule EvlDaemon.Supervisor.EventNotifier do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    child_processes = for [notifier | opts] <- active_notifiers() do
      worker(notifier, opts)
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
