defmodule EvlDaemon.EventNotifier.Mimir do
  @moduledoc """
  This module implements the EventNotifier behaviour and handles sending the
  notifications to Mimir.
  """

  alias EvlDaemon.{EventNotifier, EventSubscriber}
  use GenServer
  use EventSubscriber

  @behaviour EventNotifier

  @impl EventNotifier
  def filter(_event), do: true

  @impl EventNotifier
  def notify(event, opts) do
    do_notify(event, opts)
  end

  @impl GenServer
  def handle_info({:handle_event, event}, opts) do
    notify(event, opts)

    {:noreply, opts}
  end

  # Private functions

  defp do_notify(event, opts) do
    HTTPoison.post(service_url(opts), body(event, opts), headers())
    |> handle_response
  end

  @doc false
  defp service_url(opts) do
    host = opts |> Keyword.get(:host)
    host <> "/api/events"
  end

  @doc false
  defp headers() do
    [{"Content-Type", "application/json"}, {"Accept", "application/json"}]
  end

  @doc false
  defp body(event, opts) do
    %{
      auth_token: Keyword.fetch!(opts, :auth_token),
      device: Keyword.fetch!(opts, :device),
      event: normalized_event(event)
    }
    |> Jason.encode!()
  end

  @doc false
  defp normalized_event(event) do
    combined_description = event.description[:command] <> " " <> event.description[:data]

    %{
      event
      | description: combined_description,
        timestamp: event.timestamp |> DateTime.from_unix!()
    }
  end

  @doc false
  defp handle_response({:ok, %{status_code: 201, body: body}}) do
    body |> Jason.decode!()
  end
end
