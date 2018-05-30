defmodule EvlDaemon.Event.Command do
  @moduledoc """
  This module includes the needed functions to return human-readable descriptions for the
  event commands and their priorities.
  """

  alias EvlDaemon.TPI

  @commands %{
    "501" => [description: "Command Error", priority: :critical],
    "502" => [description: "System Error", priority: :critical],
    "505" => [description: "Login Interaction", priority: :medium],
    "510" => [description: "Keypad LED State", priority: :low],
    "511" => [description: "Keypad LED FLASH State", priority: :low],
    "601" => [description: "Zone Alarm", priority: :high],
    "602" => [description: "Zone Alarm Restore", priority: :medium],
    "603" => [description: "Zone Tamper", priority: :critical],
    "604" => [description: "Zone Tamper Restore", priority: :medium],
    "605" => [description: "Zone Fault", priority: :critical],
    "606" => [description: "Zone Fault Restore", priority: :medium],
    "609" => [description: "Zone Open", priority: :low],
    "610" => [description: "Zone Restored", priority: :medium],
    "615" => [description: "Envisalink Zone Timer Dump", priority: :low],
    "616" => [description: "Bypassed Zones Bitfield Dump", priority: :low],
    "650" => [description: "Partition Ready", priority: :low],
    "651" => [description: "Partition Not Ready", priority: :low],
    "652" => [description: "Partition Armed", priority: :medium],
    "653" => [description: "Partition Ready - Force Arming Enabled", priority: :low],
    "654" => [description: "Partition In Alarm", priority: :high],
    "655" => [description: "Partition Disarmed", priority: :medium],
    "656" => [description: "Exit Delay in Progress", priority: :medium],
    "657" => [description: "Entry Delay in Progress", priority: :medium],
    "658" => [description: "Keypad Lock-out", priority: :high],
    "659" => [description: "Partition Failed to Arm", priority: :high],
    "670" => [description: "Invalid Access Code", priority: :high],
    "671" => [description: "Function Not Available", priority: :high],
    "672" => [description: "Failure to Arm", priority: :high],
    "673" => [description: "Partition is Busy", priority: :medium],
    "674" => [description: "System Arming in Progress", priority: :medium],
    "680" => [description: "System in Installers Mode", priority: :high],
    "700" => [description: "User Closing", priority: :medium],
    "701" => [description: "Special Closing", priority: :medium],
    "702" => [description: "Partial Closing", priority: :medium],
    "750" => [description: "User Opening", priority: :medium],
    "751" => [description: "Special Opening", priority: :medium],
    "800" => [description: "Panel Battery Trouble", priority: :critical],
    "801" => [description: "Panel Battery Trouble Restore", priority: :medium],
    "802" => [description: "Panel AC Trouble", priority: :critical],
    "803" => [description: "Panel AC Restore", priority: :medium],
    "806" => [description: "System Bell Trouble", priority: :critical],
    "807" => [description: "System Bell Trouble Restore", priority: :medium],
    "814" => [description: "FTC Trouble", priority: :critical],
    "816" => [description: "Buffer Near Full", priority: :critical],
    "829" => [description: "General System Tamper", priority: :critical],
    "830" => [description: "General System Tamper Restore", priority: :medium],
    "840" => [description: "Trouble LED ON", priority: :critical],
    "841" => [description: "Trouble LED OFF", priority: :medium],
    "842" => [description: "Fire Trouble Alarm", priority: :high],
    "843" => [description: "Fire Trouble Alarm Restore", priority: :medium],
    "849" => [description: "Verbose Trouble Status", priority: :critical],
    "900" => [description: "Code Required", priority: :high],
    "912" => [description: "Command Output Pressed", priority: :high],
    "921" => [description: "Master Code Required", priority: :high],
    "922" => [description: "Installers Code Required", priority: :high],
    "S01" => [description: "Software Zone Alarm", priority: :high]
  }

  @doc """
  Return a human readable version of the command portion of the event.
  """
  def description(payload) do
    command_code = TPI.command_part(payload)

    Map.get(@commands, command_code, description: command_code)
    |> Keyword.get(:description)
  end

  @doc """
  Return priority for command portion of the event.
  """
  def priority(payload) do
    command_code = TPI.command_part(payload)

    Map.get(@commands, command_code, priority: :low)
    |> Keyword.get(:priority)
  end
end
