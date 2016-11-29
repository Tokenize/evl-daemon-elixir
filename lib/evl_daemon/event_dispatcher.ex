defmodule EvlDaemon.EventDispatcher do
  alias Experimental.GenStage
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:producer, :ok, dispatcher: GenStage.BroadcastDispatcher}
  end

  def enqueue(pid, value) do
    GenStage.cast(pid, {:enqueue, value})
  end

  def handle_cast({:enqueue, value}, state) do
    {:noreply, [value], state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
