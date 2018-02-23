defmodule EvlDaemon.Event.Guards do
  @moduledoc """
  This module defines some useful guards for use in the Event.Command and Event.Data modules.
  """

  @partition_commands ~w(650 653 654 655 656 657 658 659 660 663 664 670 671 672 673 674 701 702 751 840 841)
  @partition_zone_commands ~w(601 602 603 604)
  @zone_commands ~w(605 606 609 610)
  @keypad_commands ~w(510 511)
  @partition_armed_command ~w(652)

  defguard is_partition_command(command) when command in @partition_commands
  defguard is_partition_zone_command(command) when command in @partition_zone_commands
  defguard is_zone_command(command) when command in @zone_commands
  defguard is_partition_armed_command(command) when command in @partition_armed_command
  defguard is_keypad_command(command) when command in @keypad_commands
end
