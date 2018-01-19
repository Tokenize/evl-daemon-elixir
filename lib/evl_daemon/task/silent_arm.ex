defmodule EvlDaemon.Task.SilentArm do
  @moduledoc """
  This module implements a silent arming feature that triggers a custom alarm if a specific
  zone shows activity.

  The list of zones to monitor is configurable by passing a list to start_link(). For example:

  EvlDaemon.Task.SilentArm.start_link(zones: ["003", "008"])
  """

  use GenServer
  use EvlDaemon.EventSubscriber

  @alarm_triggers ~w(609)
  @shutdown_triggers ~w(652 674)

  # Callbacks

  def handle_info({:handle_event, %EvlDaemon.Event{command: code} = event}, state)
      when code in @alarm_triggers do
    if trigger_alarm?(event.zone, state) do
      EvlDaemon.EventDispatcher.enqueue("S01")
    end

    {:noreply, state}
  end

  def handle_info({:handle_event, %EvlDaemon.Event{command: code}}, state)
      when code in @shutdown_triggers do
    {:stop, :system_armed, state}
  end

  def handle_info({:handle_event, _zone}, state) do
    {:noreply, state}
  end

  # Private functions

  defp trigger_alarm?(zone, state) do
    state |> Keyword.get(:zones, [])
    |> Enum.member?(zone)
  end
end
