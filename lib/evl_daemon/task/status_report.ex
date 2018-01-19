defmodule EvlDaemon.Task.StatusReport do
  @moduledoc """
  This module monitors all events then returns the latest event
  triggered for each zone & partition.
  """

  use GenServer
  use EvlDaemon.EventSubscriber

  @default_status %{partitions: [], zones: []}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @default_status, name: __MODULE__)
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  # Callbacks

  def handle_info({:handle_event, event}, state) do
    {:noreply, do_update_state(event, state)}
  end

  def handle_call(:status, _sender, state) do
    {:reply, state, state}
  end

  # Private functions

  defp do_update_state(event, status) do
    partitions = status.partitions
    zones = status.zones

    partitions = do_update_partitions(event, partitions)
    zones = do_update_zones(event, zones)

    %{partitions: partitions, zones: zones}
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
end
