defmodule EvlDaemon.ConnectionSupervisor do
  use Supervisor

  def start_link(opts) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, opts)
    start_workers(sup, opts)
    result
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
  end

  def start_workers(sup, opts) do
    {:ok, connection} = Supervisor.start_child(sup, worker(EvlDaemon.Connection, [opts]))

    EvlDaemon.Connection.connect(connection)
    EvlDaemon.Connection.command(connection, "005#{opts.password}")
  end
end
