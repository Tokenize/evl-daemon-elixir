defmodule EvlDaemon.EventNotifier.Console do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles logging the notification
  to the console.
  """

  @behaviour EvlDaemon.EventNotifier

  alias Experimental.GenStage
  use GenStage
  require Logger

  def start_link(dispatcher_pid) do
    GenStage.start_link(__MODULE__, dispatcher_pid)
  end

  def init(dispatcher_pid) do
    {:consumer, :ok, subscribe_to: [{dispatcher_pid, selector: fn (event) -> filter(event) end}]}
  end

  @doc """
  Used by the dispatcher to only send events that we are interested in.
  """
  def filter(_term) do
    true
  end

  @doc """
  Log the notification for the event to the console.
  """
  def notify([{event, timestamp} | []]), do: Logger.info("#{__MODULE__}: [#{timestamp}] #{event} (#{EvlDaemon.Event.description(event)})")
  def notify([_head | tail]), do: notify(tail)

  # Callbacks

  def handle_events(events, _from, queue) do
    notify(events)

    {:noreply, [], queue}
  end
end
