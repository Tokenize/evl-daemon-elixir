defmodule EvlDaemon.Event do
  @moduledoc """
  This module includes the needed functions to return human-readable versions of the
  TPI responses.
  """

  alias EvlDaemon.{Event, TPI}

  @derive [Poison.Encoder]

  defstruct [:command, :data, :description, :priority, :partition, :zone, :timestamp]

  @doc """
  Return a new Event based on the payload and timestamp.
  """
  @spec new(payload :: String.t(), timestamp :: Calendar.datetime()) :: %Event{}
  def new(payload, timestamp) do
    %Event{
      command: TPI.command_part(payload),
      data: Event.Data.data(payload),
      description: description(payload),
      priority: Event.Command.priority(payload),
      partition: Event.Data.partition(payload),
      zone: Event.Data.zone(payload),
      timestamp: timestamp
    }
  end

  @doc """
  Return a human readable version of both the command and data portions of the event.
  """
  @spec description(payload :: String.t()) :: %{command: String.t(), data: String.t()}
  def description(payload) do
    %{
      command: Event.Command.description(payload),
      data: Event.Data.description(payload)
    }
  end
end
