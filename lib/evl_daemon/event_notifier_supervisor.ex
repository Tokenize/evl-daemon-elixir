defmodule EvlDaemon.EventNotifierSupervisor do
  use Supervisor

  def start_link(dispatcher_pid) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, dispatcher_pid)
  end

  def init(dispatcher_pid) do
    child_processes = [
      worker(EvlDaemon.EventNotifier.Console, [dispatcher_pid])
    ]

    supervise(child_processes, strategy: :one_for_one)
  end
end
