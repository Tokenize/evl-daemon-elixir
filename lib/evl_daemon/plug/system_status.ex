defmodule EvlDaemon.Plug.SystemStatus do
  import Plug.Conn

  def init(options), do: options

  def call(%Plug.Conn{request_path: "/system_status"} = conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Poison.encode!(system_status_body()))
    |> halt
  end

  def call(conn, _opts), do: conn

  # Private functions

  defp system_status_body do
    %{
      connection: configured_connection(),
      event_notifiers: configured_event_notifiers(),
      storage_engines: configured_storage_engines()
    }
  end

  defp configured_event_notifiers do
    Application.get_env(:evl_daemon, :event_notifiers, [])
    |> Enum.map(fn notifier ->
      Keyword.get(notifier, :type)
    end)
  end

  defp configured_storage_engines do
    Application.get_env(:evl_daemon, :storage_engines, [])
    |> Enum.map(fn notifier ->
      Keyword.get(notifier, :type)
    end)
  end

  defp configured_connection do
    %{
      alive?: EvlDaemon.Connection.alive?,
      host: (Application.get_env(:evl_daemon, :host) |> to_string),
      port: Application.get_env(:evl_daemon, :port)
    }
  end
end
