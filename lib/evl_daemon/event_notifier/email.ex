defmodule EvlDaemon.EventNotifier.Email do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles sending the notification
  via email.
  """

  use EvlDaemon.EventNotifier

  def filter(event) do
    Enum.member?([:high, :critical], event.priority)
  end

  def notify(event, opts), do: do_notify(event, opts)

  # Private functions

  defp do_notify(event, opts) do
    EvlDaemon.Email.Event.build(event, Keyword.get(opts, :recipient), Keyword.get(opts, :sender))
    |> EvlDaemon.Mailer.deliver_now()
  end
end
