defmodule EvlDaemon.ConnectionSupervisor do
  use Supervisor

  def start_link(opts) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    child_processes = [
      worker(EvlDaemon.Connection, [opts])
    ]

    supervise(child_processes, strategy: :one_for_one)
  end
end
