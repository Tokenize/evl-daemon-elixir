defmodule EvlDaemon.Event.Data do
  @moduledoc """
  This module includes the needed functions to return human-readable descriptions for the
  event data portion.
  """

  use Bitwise
  import EvlDaemon.Event.Guards
  alias EvlDaemon.TPI

  @doc """
  Return a human readable version of the data portion of the event.
  """
  @spec description(payload :: String.t()) :: String.t()
  def description(payload) do
    do_description(TPI.command_part(payload), TPI.data_part(payload))
  end

  @doc """
  Return the event's partition (if applicable).
  """
  @spec partition(payload :: String.t()) :: String.t()
  def partition(payload) do
    do_partition(TPI.command_part(payload), TPI.data_part(payload))
  end

  @doc """
  Return the event's zone (if applicable).
  """
  @spec zone(payload :: String.t()) :: String.t()
  def zone(payload) do
    do_zone(TPI.command_part(payload), TPI.data_part(payload))
  end

  @doc """
  Return the event's data (excluding the zone and partition).
  """
  @spec data(payload :: String.t()) :: String.t()
  def data(payload) do
    do_data(TPI.command_part(payload), TPI.data_part(payload))
  end

  # Private functions

  defp do_description("505", code) do
    case code do
      "0" -> "Fail"
      "1" -> "Successful"
      "2" -> "Timed out"
      "3" -> "Password request"
    end
  end

  defp do_description(command, code) when is_keypad_command(command) do
    state = code |> String.to_integer(16)

    keypad_states =
      [
        {"Ready LED", state &&& 1},
        {"Armed LED", state &&& 2},
        {"Memory LED", state &&& 4},
        {"Bypass LED", state &&& 8},
        {"Trouble LED", state &&& 16},
        {"Program LED", state &&& 32},
        {"Fire LED", state &&& 64},
        {"Backlight LED", state &&& 128}
      ]
      |> Enum.filter(&(elem(&1, 1) != 0))
      |> Enum.map(&elem(&1, 0))

    "[" <> Enum.join(keypad_states, ", ") <> "]"
  end

  defp do_description("652", <<partition::binary-size(1), mode::binary>>) do
    "[Partition: " <>
      do_partition_description(partition) <> ", Mode: " <> do_zone_armed_mode(mode) <> "]"
  end

  defp do_description(command, <<partition::binary-size(1), zone::binary>>)
       when is_partition_zone_command(command) do
    "[Partition: " <>
      do_partition_description(partition) <> ", Zone: " <> do_zone_description(zone) <> "]"
  end

  defp do_description(command, zone) when is_zone_command(command) do
    "[Zone: " <> do_zone_description(zone) <> "]"
  end

  defp do_description(command, partition) when is_partition_command(command) do
    "[Partition: " <> do_partition_description(partition) <> "]"
  end

  defp do_description("849", code) do
    state = code |> String.to_integer(16)

    trouble_statuses =
      [
        {"Service is Required", state &&& 1},
        {"AC Power Lost", state &&& 2},
        {"Telephone Line Fault", state &&& 4},
        {"Failure to Communicate", state &&& 8},
        {"Sensor/Zone Fault", state &&& 16},
        {"Sensor/Zone Tamper", state &&& 32},
        {"Sensor/Zone Low Battery", state &&& 64},
        {"Loss of Time", state &&& 128}
      ]
      |> Enum.filter(&(elem(&1, 1) != 0))
      |> Enum.map(&elem(&1, 0))

    "[" <> Enum.join(trouble_statuses, ", ") <> "]"
  end

  defp do_description(_command, code) do
    code
  end

  defp do_zone_description(zone) do
    zone_desc = Application.get_env(:evl_daemon, :zones) |> Map.get(zone)

    case zone_desc do
      nil -> zone
      _ -> "#" <> String.trim_leading(zone, "0") <> " " <> zone_desc
    end
  end

  defp do_partition_description(partition) do
    partition_desc = Application.get_env(:evl_daemon, :partitions) |> Map.get(partition)

    case partition_desc do
      nil -> partition
      _ -> "#" <> partition <> " " <> partition_desc
    end
  end

  defp do_zone_armed_mode(code) do
    case code do
      "0" -> "Away"
      "1" -> "Stay"
      "2" -> "Zero-Entry-Away"
      "3" -> "Zero-Entry-Stay"
    end
  end

  defp do_partition(command, data) when is_partition_command(command) do
    data
  end

  defp do_partition(command, data) when is_partition_zone_command(command) do
    data
    |> String.at(0)
  end

  defp do_partition(command, data) when is_partition_armed_command(command) do
    data
    |> String.at(0)
  end

  defp do_partition(_command, _data) do
    nil
  end

  defp do_zone(command, data) when is_zone_command(command) do
    data
  end

  defp do_zone(command, data) when is_partition_zone_command(command) do
    data
    |> String.slice(1..-1)
  end

  defp do_zone(_command, _data) do
    nil
  end

  defp do_data(cmd, <<_::binary-size(1), "">>) when is_partition_command(cmd), do: nil
  defp do_data(cmd, <<_::binary-size(1), dt::binary>>) when is_partition_command(cmd), do: dt
  defp do_data(cmd, <<_::binary-size(3), "">>) when is_zone_command(cmd), do: nil
  defp do_data(cmd, <<_::binary-size(3), dt::binary>>) when is_zone_command(cmd), do: dt
  defp do_data(cmd, <<_::binary-size(4), "">>) when is_partition_zone_command(cmd), do: nil
  defp do_data(cmd, <<_::binary-size(4), dt::binary>>) when is_partition_zone_command(cmd), do: dt

  defp do_data(_command, dt), do: dt
end
