defmodule EvlDaemon.Supervisor do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    child_processes = [
      supervisor(EvlDaemon.Supervisor.EventDispatcher, []),
      supervisor(EvlDaemon.Supervisor.Connection, []),
      supervisor(EvlDaemon.Supervisor.Task, []),
      worker(EvlDaemon.Router, [])
    ]

    supervise(child_processes, strategy: :one_for_one)
  end
end
