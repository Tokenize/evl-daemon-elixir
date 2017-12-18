defmodule EvlDaemon.Supervisor do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    child_processes = [
      EvlDaemon.Supervisor.EventDispatcher,
      EvlDaemon.Supervisor.Connection,
      EvlDaemon.Supervisor.Task,
      EvlDaemon.Router,
    ]

    Supervisor.init(child_processes, strategy: :one_for_one)
  end
end
