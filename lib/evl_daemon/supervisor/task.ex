defmodule EvlDaemon.Supervisor.Task do
  use Supervisor

  def start_link(opts \\ []) do
    {:ok, _pid} = Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    Supervisor.init([EvlDaemon.Task.SilentArm], strategy: :simple_one_for_one)
  end
end
