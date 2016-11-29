defmodule EvlDaemon.EventQueue do
  alias Experimental.GenStage
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :queue.new)
  end

  def init(queue) do
    {:producer, queue, dispatcher: GenStage.BroadcastDispatcher}
  end

  def length(pid) do
    GenStage.call(pid, :length)
  end

  def push(pid, value) do
    GenStage.cast(pid, {:push, value})
  end

  def pop(pid) do
    GenStage.call(pid, :pop)
  end

  def handle_cast({:push, value}, queue) do
    queue = :queue.in(value, queue)

    {:noreply, [value], queue}
  end

  def handle_call(:length, _from, queue) do
    {:reply, :queue.len(queue), [], queue}
  end

  def handle_call(:pop, _from, queue) do
    {result, queue} = :queue.out(queue)

    case result do
      {:value, value} ->
        {:reply, value, [], queue}
      :empty ->
        {:reply, nil, [], queue}
    end
  end

  def handle_demand(_demand, queue) do
    {:noreply, [], queue}
  end
end
