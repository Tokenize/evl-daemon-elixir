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
  def notify(_event, opts \\ [])
  def notify([event | []], _opts), do: Logger.info("#{__MODULE__}: [#{event.timestamp}] #{event.command}:#{event.data} (#{event.description})")
  def notify([_head | tail], opts), do: notify(tail, opts)

  # Callbacks

  def handle_events(events, _from, opts) do
    notify(events)

    {:noreply, [], opts}
  end
end
