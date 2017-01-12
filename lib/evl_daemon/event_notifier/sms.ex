defmodule EvlDaemon.EventNotifier.SMS do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles sending the notification
  via SMS.
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

  def do_notify(event, opts) do
    headers = [content_type_header(), authorization_header(opts)]

    HTTPoison.post(service_url(opts), body(event, opts), headers)
    |> handle_response
  end

  defp authorization_header(opts) do
    sid = Keyword.get(opts, :sid)
    auth_token = Keyword.get(opts, :auth_token)

    hashed_credentials = (sid <> ":" <> auth_token) |> Base.encode64
    {"Authorization", ("Basic " <> hashed_credentials)}
  end

  defp content_type_header do
    {"Content-Type", "application/x-www-form-urlencoded; charset=UTF-8"}
  end

  defp body(event, opts) do
    timestamp = event.timestamp |> DateTime.from_unix! |> DateTime.to_string
    notification_message = "[EvlDaemon] Event " <> event.description <> "(#{event.command}:#{event.data}) triggered at " <> timestamp

    %{
      From: Keyword.get(opts, :from),
      To: Keyword.get(opts, :to),
      Body: notification_message
    }
    |> URI.encode_query
  end

  defp service_url(opts) do
    "https://api.twilio.com/2010-04-01/Accounts/" <> Keyword.get(opts, :sid) <> "/Messages.json"
  end

  defp handle_response({:ok, %{status_code: 201, body: body}}) do
    body |> Poison.decode!
  end
end
