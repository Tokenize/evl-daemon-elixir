defmodule EvlDaemon.EventNotifier.Email do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles sending the notification
  via email.
  """
  @behaviour EvlDaemon.EventNotifier

  alias Experimental.GenStage
  alias SendGrid.{Mailer, Email}
  use GenStage
  require Logger

  @recipients Application.get_env(:evl_daemon, :recipients)

  def start_link(dispatcher_pid) do
    GenStage.start_link(__MODULE__, dispatcher_pid)
  end

  def init(dispatcher_pid) do
    {:consumer, :ok, subscribe_to: [{dispatcher_pid, selector: fn (event) -> filter(event) end}]}
  end

  @doc """
  Used by the dispatcher to only send events that we are interested in.
  """
  def filter({event, _timestamp}) do
    Enum.member?(~w(601 603 605 620 621 623 625), String.slice(event, 0..2))
  end

  @doc """
  Send the notification for the event via email.
  """

  def notify([{event, timestamp} | []]), do: do_notify(event, timestamp)
  def notify([_head | tail]), do: notify(tail)

  # Callbacks

  def handle_events(events, _from, queue) do
    notify(events)

    {:noreply, [], queue}
  end

  # Private functions

  defp do_notify(event, timestamp) do
    utc_timestamp =
      timestamp
      |> DateTime.from_unix!
      |> DateTime.to_string

    email = Email.build()
    |> Email.put_from("noreply@tokenize.ca")
    |> Email.add_to("zaid@tokenize.ca")
    |> Email.put_subject("Event [#{event}] triggered on #{timestamp}")
    |> Email.put_text("Event: #{EvlDaemon.Event.description(event)}, timestamp: #{utc_timestamp}.")
    :ok = Mailer.send(email)
  end
end
