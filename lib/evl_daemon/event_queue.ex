defmodule EvlDaemon.EventQueue do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :queue.new)
  end

  def push(pid, value) do
    GenServer.cast(pid, {:push, value})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  def handle_cast({:push, value}, queue) do
    queue = :queue.in(value, queue)

    {:noreply, queue}
  end

  def handle_call(:pop, _from, queue) do
    {result, queue} = :queue.out(queue)

    case result do
      {:value, value} ->
        {:reply, value, queue}
      :empty ->
        {:reply, nil, queue}
    end
  end
end
