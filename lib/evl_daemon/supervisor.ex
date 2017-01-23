defmodule EvlDaemon.Supervisor do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init(opts) do
    child_processes = [
      supervisor(Registry, [:duplicate, EvlDaemon.Registry]),
      worker(EvlDaemon.EventDispatcher, []),
      supervisor(EvlDaemon.Supervisor.Connection, []),
      supervisor(EvlDaemon.Supervisor.EventNotifier, [])
    ]

    supervise(child_processes, strategy: :one_for_one)
  end
end
