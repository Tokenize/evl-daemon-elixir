defmodule EvlDaemon.Supervisor.Connection do
  use Supervisor

  def start_link(_opts) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init(opts) do
    child_processes = [
      EvlDaemon.Connection,
      {EvlDaemon.Client, [opts]}
    ]

    Supervisor.init(child_processes, strategy: :rest_for_one)
  end
end
