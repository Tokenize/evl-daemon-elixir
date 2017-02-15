defmodule EvlDaemon.Plug.Events do
  import Plug.Conn

  def init(options), do: options

  def call(%Plug.Conn{request_path: "/events"} = conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(events()))
    |> halt
  end

  def call(conn, _opts), do: conn

  # Private functions

  defp events do
    EvlDaemon.StorageEngine.Memory.all
  end
end
