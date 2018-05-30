defmodule EvlDaemon.EventDispatcher do
  @moduledoc """
  This module implements a dispatcher using GenStage and it acts as a producer
  of events.
  """

  use GenServer
  use EvlDaemon.ErrorNotifier
  alias EvlDaemon.Event

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
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
  def subscribe(args) do
    Registry.register(EvlDaemon.Registry, "event_notifiers", args)
  end

  # Callbacks

  def handle_cast({:enqueue, value, timestamp}, _state) do
    event = Event.new(value, timestamp)

    do_dispatch_event(event)

    {:noreply, event}
  end

  # Private functions

  defp do_timestamp do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  defp do_dispatch_event(event) do
    Registry.dispatch(EvlDaemon.Registry, "event_notifiers", fn notifiers ->
      for {pid, _} <- notifiers do
        send(pid, {:handle_event, event})
      end
    end)
  end
end
