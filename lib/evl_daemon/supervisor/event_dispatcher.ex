defmodule EvlDaemon.Supervisor.EventDispatcher do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    child_processes = [
      supervisor(Registry, [:duplicate, EvlDaemon.Registry]),
      worker(EvlDaemon.EventDispatcher, []),
      supervisor(EvlDaemon.Supervisor.EventNotifier, [])
    ]

    supervise(child_processes, strategy: :rest_for_one)
  end
end
