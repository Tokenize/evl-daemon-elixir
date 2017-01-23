defmodule EvlDaemon.Supervisor.Connection do
  use Supervisor

  def start_link do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init(opts) do
    child_processes = [
      worker(EvlDaemon.Connection, []),
      worker(EvlDaemon.Client, [opts])
    ]

    supervise(child_processes, strategy: :rest_for_one)
  end
end
