defmodule EvlDaemon.ConnectionSupervisor do
  use Supervisor

  def start_link(opts) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    child_processes = [
      worker(EvlDaemon.Connection, [opts])
    ]

    EvlDaemon.Connection.connect(connection)
    EvlDaemon.Connection.command(connection, "005#{opts.password}")
    supervise(child_processes, strategy: :one_for_one)
  end
end
