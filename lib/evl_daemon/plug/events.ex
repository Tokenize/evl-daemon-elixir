defmodule EvlDaemon.Plug.Events do
  import Plug.Conn
  alias EvlDaemon.StorageEngine

  def init(options), do: options

  def call(%Plug.Conn{request_path: "/events"} = conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Jason.encode!(encoded_events(conn, events())))
    |> halt
  end

  def call(conn, _opts), do: conn

  # Private functions

  defp events do
    pid = GenServer.whereis(EvlDaemon.StorageEngine.Memory)

    case pid do
      nil -> []
      _ -> StorageEngine.Memory.all(order: :desc)
    end
  end

  defp encoded_events(%Plug.Conn{query_params: %{"timezone_offset" => offset}}, events)
       when is_binary(offset) do
    events
    |> Enum.map(fn event ->
      %{event | timestamp: convert_timestamp(event.timestamp, offset)}
    end)
  end

  defp encoded_events(_conn, events) do
    events
  end

  defp convert_timestamp(timestamp, hour_offset) do
    offset_in_seconds = (hour_offset |> String.to_integer()) * 3600

    timestamp
    |> DateTime.from_unix!()
    |> DateTime.to_naive()
    |> NaiveDateTime.add(offset_in_seconds, :second)
  end
end
