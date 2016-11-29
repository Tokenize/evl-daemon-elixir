defmodule EvlDaemon.EventNotifier.Console do
  @behaviour EvlDaemon.EventNotifier

  alias Experimental.GenStage
  use GenStage
  require Logger

  def start_link do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :ok}
  end

  def filter(_term) do
    true
  end

  def notify(event) do
    Logger.info("#{__MODULE__}: #{event}")
  end

  def handle_events(events, _from, queue) do
    Enum.each(events, fn (event) -> notify(event) end)

    {:noreply, [], queue}
  end
end
