defmodule EvlDaemon.Supervisor.EventDispatcher do
  use Supervisor

  def start_link(_opts) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    child_processes = [
      {Registry, keys: :duplicate, name: EvlDaemon.Registry},
      EvlDaemon.EventDispatcher,
      EvlDaemon.Supervisor.EventNotifier
    ]

    Supervisor.init(child_processes, strategy: :rest_for_one)
  end
end
