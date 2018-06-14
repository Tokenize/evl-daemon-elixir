defmodule EvlDaemon.Task.StatusReport do
  @moduledoc """
  This module monitors all events then returns the latest event
  triggered for each zone & partition.
  """

  use GenServer
  use EvlDaemon.EventSubscriber
  alias EvlDaemon.{Connection, Client, Event, EventDispatcher}

  @default_status %{partitions: [], zones: [], armed_states: [], latest_event: nil}
  @query_status_delay 1000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init([query_status: "true"] = _opts) do
    EventDispatcher.subscribe([])

    Process.send_after(__MODULE__, :query_status, @query_status_delay)

    {:ok, @default_status}
  end

  def init(_opts) do
    EventDispatcher.subscribe([])

    {:ok, @default_status}
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  # Callbacks

  def handle_info({:handle_event, event}, state) do
    {:noreply, do_update_state(event, state)}
  end

  def handle_info(:query_status, state) do
    if Connection.alive?() do
      Client.status_report()
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
    armed_states = status.armed_states

    partitions = do_update_partitions(event, partitions)
    zones = do_update_zones(event, zones)
    armed_states = do_update_armed_states(event, armed_states)

    %{partitions: partitions, zones: zones, armed_states: armed_states, latest_event: event}
  end

  defp do_update_partitions(%Event{partition: partition} = event, partitions)
       when is_binary(partition) do
    List.keystore(partitions, event.partition, 0, {event.partition, event.description})
  end

  defp do_update_partitions(%Event{partition: partition}, partitions)
       when is_nil(partition) do
    partitions
  end

  defp do_update_zones(%Event{zone: zone} = event, zones) when is_binary(zone) do
    List.keystore(zones, event.zone, 0, {event.zone, event.description})
  end

  defp do_update_zones(%Event{zone: zone}, zones) when is_nil(zone) do
    zones
  end

  defp do_update_armed_states(%EvlDaemon.Event{command: command} = event, armed_states)
       when command == "652" do
    List.keystore(
      armed_states,
      event.partition,
      0,
      {event.partition,
       "Armed in " <> do_partition_armed_mode_description(event.data) <> " mode."}
    )
  end

  defp do_update_armed_states(%EvlDaemon.Event{command: command} = event, armed_states)
       when command == "655" do
    List.keystore(armed_states, event.partition, 0, {event.partition, "Unarmed."})
  end

  defp do_update_armed_states(%EvlDaemon.Event{command: command} = event, armed_states)
       when command in ~w(659 672) do
    List.keystore(armed_states, event.partition, 0, {event.partition, "Failed to arm."})
  end

  defp do_update_armed_states(_event, armed_states) do
    armed_states
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
