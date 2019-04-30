defmodule EvlDaemon.EventNotifier.Console do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles logging the notification
  to the console.
  """

  alias EvlDaemon.{EventNotifier, EventSubscriber}
  require Logger
  use GenServer
  use EventSubscriber

  @behaviour EventNotifier

  @impl EventNotifier
  def filter(_event), do: true

  @impl EventNotifier
  def notify(event, _opts \\ []) do
    description = (event.description.command <> " " <> event.description.data) |> String.trim()

    Logger.info(
      "#{__MODULE__}: [#{event.timestamp}] #{event.command}:#{event.data} (#{description})"
    )
  end

  @impl GenServer
  def handle_info({:handle_event, event}, opts) do
    notify(event, opts)

    {:noreply, opts}
  end
end
