defmodule EvlDaemon.EventNotifier.Console do
  @behaviour EvlDaemon.EventNotifier

  alias Experimental.GenStage
  use GenStage
  require Logger

  def start_link(dispatcher_pid) do
    GenStage.start_link(__MODULE__, dispatcher_pid)
  end

  def init(dispatcher_pid) do
    {:consumer, :ok, subscribe_to: [dispatcher_pid]}
  end

  def filter(_term) do
    true
  end

  def notify(event) do
    Logger.info("#{__MODULE__}: #{event} (#{EvlDaemon.Event.description(event)})")
  end

  def handle_events(events, _from, queue) do
    Enum.each(events, fn (event) -> notify(event) end)

    {:noreply, [], queue}
  end
end
