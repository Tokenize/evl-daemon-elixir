defmodule EvlDaemon.Supervisor.Task do
  use DynamicSupervisor

  def start_link(opts \\ []) do
    {:ok, _pid} = DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
