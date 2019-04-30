defmodule EvlDaemon.EventNotifier.Email do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles sending the notification
  via email.
  """

  alias EvlDaemon.{Email, Mailer}
  alias EvlDaemon.{EventNotifier, EventSubscriber}
  use GenServer
  use EventSubscriber

  @behaviour EventNotifier

  @impl EventNotifier
  def filter(event) do
    Enum.member?([:high, :critical], event.priority)
  end

  @impl EventNotifier
  def notify(event, opts), do: do_notify(event, opts)

  @impl GenServer
  def handle_info({:handle_event, event}, opts) do
    if filter(event), do: notify(event, opts)

    {:noreply, opts}
  end

  # Private functions

  defp do_notify(event, opts) do
    Email.Event.build(event, Keyword.get(opts, :recipient), Keyword.get(opts, :sender))
    |> Mailer.deliver_now()
  end
end
