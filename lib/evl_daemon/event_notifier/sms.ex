defmodule EvlDaemon.EventNotifier.SMS do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles sending the notification
  via SMS.
  """

  require Logger
  use EvlDaemon.EventNotifier

  def filter(event) do
    Enum.member?([:high, :critical], event.priority)
  end

  def notify(event, opts), do: do_notify(event, opts)

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
