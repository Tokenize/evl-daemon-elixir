defmodule EvlDaemon.Event do
  @moduledoc """
  This module includes the needed functions to return human-readable versions of the
  TPI responses.
  """

  defstruct [:command, :data, :description, :priority, :timestamp]

  @command_map %{
    "501" => [description: "Command Error", priority: :critical],
    "502" => [description: "System Error", priority: :critical],
    "505" => [description: "Login Interaction", priority: :medium],
    "601" => [description: "Zone Alarm", priority: :high],
    "602" => [description: "Zone Alarm Restore", priority: :medium],
    "603" => [description: "Zone Tamper", priority: :critical],
    "604" => [description: "Zone Tamper Restore", priority: :medium],
    "605" => [description: "Zone Fault", priority: :critical],
    "606" => [description: "Zone Fault Restore", priority: :medium],
    "609" => [description: "Zone Open", priority: :low],
    "610" => [description: "Zone Restored", priority: :medium],
    "650" => [description: "Partition Ready", priority: :low],
    "651" => [description: "Partition Not Ready", priority: :low],
    "652" => [description: "Partition Armed", priority: :medium],
    "653" => [description: "Partition Ready - Force Arming Enabled", priority: :low],
    "654" => [description: "Partition In Alarm", priority: :high],
    "655" => [description: "Partition Disarmed", priority: :medium],
    "656" => [description: "Exit Delay in Progress", priority: :medium],
    "657" => [description: "Entry Delay in Progress", priority: :medium]
  }

  @doc """
  Return a new Event based on the payload and timestamp.
  """
  def new(payload, timestamp) do
    %EvlDaemon.Event{
      command: EvlDaemon.TPI.command_part(payload),
      data: EvlDaemon.TPI.data_part(payload),
      description: description(payload),
      priority: command_priority(payload),
      timestamp: timestamp,
    }
  end

  @doc """
  Return a human readable version of both the command and data portions of the event.
  """
  def description(payload) do
    command_description(payload) <> " " <> data_description(payload)
  end

  @doc """
  Return a human readable version of the command portion of the event.
  """
  def command_description(payload) do
    command_code = EvlDaemon.TPI.command_part(payload)
    Map.get(@command_map, command_code, [description: command_code])
    |> Keyword.get(:description)
  end

  @doc """
  Return a human readable version of the data portion of the event.
  """
  def data_description(payload) do
    do_data_description(EvlDaemon.TPI.command_part(payload), EvlDaemon.TPI.data_part(payload))
  end

  @doc """
  Return priority for command portion of the event.
  """
  def command_priority(payload) do
    command_code = EvlDaemon.TPI.command_part(payload)
    Map.get(@command_map, command_code, [priority: :low])
    |> Keyword.get(:priority)
  end

  # Private functions

  defp do_data_description("505", code) do
    case code do
      "0" -> "Fail"
      "1" -> "Successful"
      "2" -> "Timed out"
      "3" -> "Password request"
    end
  end

  defp do_data_description(command, <<partition::binary-size(1), zone::binary>>) when command in ~w(601 602 603 604) do
    "[Partition: " <> partition <> ", Zone: " <> zone <> "]"
  end

  defp do_data_description(command, zone) when command in ~w(605 606 609 610) do
    "[Zone: " <> zone <> "]"
  end

  defp do_data_description(_command, code) do
    code
  end
end
