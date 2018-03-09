defmodule EvlDaemon.Task.StatusReport do
  @moduledoc """
  This module monitors all events then returns the latest event
  triggered for each zone & partition.
  """

  use GenServer
  use EvlDaemon.EventSubscriber

  @default_status %{partitions: [], zones: [], arming_modes: []}
  @query_status_delay 0

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init([query_status: "true"] = opts) do
    EvlDaemon.EventDispatcher.subscribe(opts)

    {:ok, @default_status, @query_status_delay}
  end

  def init(_opts) do
    EvlDaemon.EventDispatcher.subscribe([])

    {:ok, @default_status}
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  # Callbacks

  def handle_info({:handle_event, event}, state) do
    {:noreply, do_update_state(event, state)}
  end

  def handle_info(:timeout, state) do
    if EvlDaemon.Connection.alive?() do
      EvlDaemon.Client.status_report()
    end

    {:noreply, state}
  end

  def handle_call(:status, _sender, state) do
    {:reply, state, state}
  end

  # Private functions

  defp do_update_state(event, status) do
    partitions = status.partitions
    zones = status.zones
    arming_modes = status.arming_modes

    partitions = do_update_partitions(event, partitions)
    zones = do_update_zones(event, zones)
    arming_modes = do_update_arming_modes(event, arming_modes)

    %{partitions: partitions, zones: zones, arming_modes: arming_modes}
  end

  defp do_update_partitions(%EvlDaemon.Event{partition: partition} = event, partitions)
       when is_binary(partition) do
    List.keystore(partitions, event.partition, 0, {event.partition, event.description})
  end

  defp do_update_partitions(%EvlDaemon.Event{partition: partition}, partitions)
       when is_nil(partition) do
    partitions
  end

  defp do_update_zones(%EvlDaemon.Event{zone: zone} = event, zones) when is_binary(zone) do
    List.keystore(zones, event.zone, 0, {event.zone, event.description})
  end

  defp do_update_zones(%EvlDaemon.Event{zone: zone}, zones) when is_nil(zone) do
    zones
  end

  defp do_update_arming_modes(%EvlDaemon.Event{command: command} = event, arming_modes)
       when command == "652" do
    List.keystore(
      arming_modes,
      event.partition,
      0,
      {event.partition,
       "Armed in " <> do_partition_armed_mode_description(event.data) <> " mode."}
    )
  end

  defp do_update_arming_modes(%EvlDaemon.Event{command: command} = event, arming_modes)
       when command == "655" do
    List.keystore(arming_modes, event.partition, 0, {event.partition, "Unarmed."})
  end

  defp do_update_arming_modes(%EvlDaemon.Event{command: command} = event, arming_modes)
       when command in ~w(659 672) do
    List.keystore(arming_modes, event.partition, 0, {event.partition, "Failed to arm."})
  end

  defp do_update_arming_modes(_event, arming_modes) do
    arming_modes
  end

  defp do_partition_armed_mode_description(<<_partition::binary-size(1), mode::binary-size(1)>>) do
    case mode do
      "0" -> "Away"
      "1" -> "Stay"
      "2" -> "Zero-Entry-Away"
      "3" -> "Zero-Entry-Stay"
    end
  end
end
