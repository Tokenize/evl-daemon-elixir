defmodule EvlDaemon.EventNotifier.Console do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles logging the notification
  to the console.
  """

  require Logger
  use EvlDaemon.EventNotifier

  def filter(_event), do: true

  def notify(event, _opts \\ []) do
    description = (event.description.command <> " " <> event.description.data) |> String.trim()

    Logger.info(
      "#{__MODULE__}: [#{event.timestamp}] #{event.command}:#{event.data} (#{description})"
    )
  end
end
