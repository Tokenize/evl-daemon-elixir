defmodule EvlDaemon.Supervisor do
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
    {:ok, dispatcher} = Supervisor.start_child(sup, worker(EvlDaemon.EventDispatcher, []))

    opts = %{opts | event_dispatcher: dispatcher}

    Supervisor.start_child(sup, supervisor(EvlDaemon.Supervisor.Connection, [opts]))
    Supervisor.start_child(sup, supervisor(EvlDaemon.Supervisor.EventNotifier, [dispatcher]))
  end
end
