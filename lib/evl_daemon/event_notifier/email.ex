defmodule EvlDaemon.EventNotifier.Email do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles sending the notification
  via email.
  """
  @behaviour EvlDaemon.EventNotifier

  alias Experimental.GenStage
  use GenStage
  require Logger

  def start_link(dispatcher_pid, opts) do
    GenStage.start_link(__MODULE__, [dispatcher_pid | opts])
  end

  def init([dispatcher_pid | opts]) do
    {:consumer, opts, subscribe_to: [{dispatcher_pid, selector: fn (event) -> filter(event) end}]}
  end

  @doc """
  Used by the dispatcher to only send events that we are interested in.
  """
  def filter(event) do
    Enum.member?([:high, :critical], event.priority)
  end

  @doc """
  Send the notification for the event via email.
  """

  def notify([event | []], opts), do: do_notify(event, opts)
  def notify([_head | tail], opts), do: notify(tail, opts)

  # Callbacks

  def handle_events(events, _from, opts) do
    notify(events, opts)

    {:noreply, [], opts}
  end

  # Private functions

  defp do_notify(event, opts) do
    EvlDaemon.Email.Event.build(event, Keyword.get(opts, :recipient), Keyword.get(opts, :sender))
    |> EvlDaemon.Mailer.deliver_now
  end
end
