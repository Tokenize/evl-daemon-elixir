defmodule EvlDaemon.EventDispatcher do
  @moduledoc """
  This module implements a dispatcher using GenStage and it acts as a producer
  of events.
  """

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, []}
  end
  @doc """
  Enqueue event and dispatch it as soon as possible.
  """
  def enqueue(value) do
    GenServer.cast(__MODULE__, {:enqueue, value, do_timestamp()})
  end

  @doc """
  Subscribe the caller in order too receive event notifications.
  """
  def subscribe(filter) do
    Registry.register(EvlDaemon.Registry, "event_notifiers", filter)
  end

  # Callbacks

  def handle_cast({:enqueue, value, timestamp}, state) do
    event = EvlDaemon.Event.new(value, timestamp)

    do_dispatch_event(event)

    {:noreply, event}
  end

  # Private functions

  def do_timestamp do
    DateTime.utc_now |> DateTime.to_unix
  end

  defp do_dispatch_event(event) do
    Registry.dispatch(EvlDaemon.Registry, "event_notifiers", fn notifiers ->
      for {pid, filter} <- notifiers do
        if do_notify?(pid, filter, event) do
           send(pid, {:handle_events, [event]})
        end
      end
    end)
  end

  defp do_notify?(pid, {module, func}, event) do
    apply(module, func, [event])
  end
end
