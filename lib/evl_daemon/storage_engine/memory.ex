defmodule EvlDaemon.StorageEngine.Memory do
  @moduledoc """
  This module implements a simple in-memory queue for events. The maximum
  allowed number of events stored is configurable.

  If the limit is reached on the number of events stored then the oldest
  event gets deleted.
  """

  use GenServer
  require Logger

  @default_maxiumum_events "1000"

  def start_link(opts) do
    maximum_events = (Keyword.get(opts, :maximum_events, @default_maxiumum_events) |> String.to_integer)
    state = {:queue.new, 0, maximum_events}

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    EvlDaemon.EventDispatcher.subscribe([])

    {:ok, state}
  end

  @doc """
  Return a list of all the events in the queue.
  """
  def all do
    GenServer.call(__MODULE__, :all)
  end

  # Callbacks

  def handle_call(:all, _sender, {queue, _queue_size, _maximum_events} = state) do
    {:reply, :queue.to_list(queue), state}
  end

  def handle_info({:handle_event, event}, {queue, queue_size, maximum_events}) do
    queue = :queue.in(event, queue)

    state = cond do
      queue_size >= maximum_events -> {:queue.drop(queue), queue_size, maximum_events}
      true -> {queue, queue_size + 1, maximum_events}
    end

    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end
end
