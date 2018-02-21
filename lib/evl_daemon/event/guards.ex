defmodule EvlDaemon.Event.Guards do
  @moduledoc """
  This module defines some useful guards for use in the Event.Command and Event.Data modules.
  """

  defguard is_partition_armed_command(command) when command in ~w(652)
end
