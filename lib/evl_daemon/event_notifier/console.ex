defmodule EvlDaemon.EventNotifier.Console do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles logging the notification
  to the console.
  """

  require Logger
  use EvlDaemon.EventNotifier

  def filter(_event), do: true

  def notify(event, _opts \\ []),
    do:
      Logger.info(
        "#{__MODULE__}: [#{event.timestamp}] #{event.command}:#{event.data} (#{event.description})"
      )
end
