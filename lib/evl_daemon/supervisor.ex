defmodule EvlDaemon.Supervisor do
  use Supervisor

  def start_link(opts) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    child_processes = [
      worker(EvlDaemon.EventDispatcher, []),
      supervisor(EvlDaemon.Supervisor.Connection, [opts]),
      supervisor(EvlDaemon.Supervisor.EventNotifier, [])
    ]

    supervise(child_processes, strategy: :one_for_one)
  end
end
