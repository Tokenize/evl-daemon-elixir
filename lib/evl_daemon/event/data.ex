defmodule EvlDaemon.Event.Data do
  @moduledoc """
  This module includes the needed functions to return human-readable descriptions for the
  event data portion.
  """

  use Bitwise

  @doc """
  Return a human readable version of the data portion of the event.
  """
  def description(payload) do
    do_description(EvlDaemon.TPI.command_part(payload), EvlDaemon.TPI.data_part(payload))
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

  defp do_description(command, code) when command in ~w(510 511) do
    state = (code |> String.to_integer(16))
    keypad_states = [
      {"Ready LED", state &&& 1},
      {"Armed LED", state &&& 2},
      {"Memory LED", state &&& 4},
      {"Bypass LED", state &&& 8},
      {"Trouble LED", state &&& 16},
      {"Program LED", state &&& 32},
      {"Fire LED", state &&& 64},
      {"Backlight LED", state &&& 128}
    ]
    |> Enum.filter_map(&(elem(&1, 1) != 0), &(elem(&1, 0)))

    "[" <> Enum.join(keypad_states, ", ") <> "]"
  end

  defp do_description("652", <<partition::binary-size(1), mode::binary>>) do
    "[Partition: " <> partition <> ", Mode: " <> do_zone_armed_mode(mode) <> "]"
  end

  defp do_description(command, <<partition::binary-size(1), zone::binary>>) when command in ~w(601 602 603 604) do
    "[Partition: " <> partition <> ", Zone: " <> do_zone_description(zone) <> "]"
  end

  defp do_description(command, zone) when command in ~w(605 606 609 610) do
    "[Zone: " <> do_zone_description(zone) <> "]"
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

  defp do_zone_armed_mode(code) do
    case code do
      "0" -> "Away"
      "1" -> "Stay"
      "2" -> "Zero-Entry-Away"
      "3" -> "Zero-Entry-Stay"
    end
  end
end
