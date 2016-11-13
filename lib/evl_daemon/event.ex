defmodule EvlDaemon.Event do
  @moduledoc """
  This module includes the needed functions to return human-readable versions of the
  TPI responses.
  """

  @command_map %{
    "500" => "Command Acknowledge", "501" => "Command Error", "502" => "System Error",
    "505" => "Login Interaction",
    "601" => "Zone Alarm", "602" => "Zone Alarm Restore",
    "603" => "Zone Tamper", "604" => "Zone Tamper Restore",
    "605" => "Zone Fault", "606" => "Zone Fault Restore",
    "609" => "Zone Open", "610" => "Zone Restored",
    "650" => "Partition Ready", "651" => "Partition Not Ready",
    "652" => "Partition Armed", "653" => "Partition Ready - Force Arming Enabled",
    "654" => "Partition In Alarm", "655" => "Partition Disarmed",
    "656" => "Exit Delay in Progress", "657" => "Entry Delay in Progress"
  }

  def description(payload) do
    command_description(payload) <> ", " <> data_description(payload)
  end

  def command_description(payload) do
    command_code = EvlDaemon.TPI.command_part(payload)
    Map.get(@command_map, command_code, command_code)
  end

  def data_description(payload) do
    case EvlDaemon.TPI.data_part(payload) do
      "" -> "containing no data."
      data_part -> "containing data of #{data_part}."
    end
  end
end
