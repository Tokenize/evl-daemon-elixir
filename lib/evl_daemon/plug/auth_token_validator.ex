defmodule EvlDaemon.Plug.AuthTokenValidator do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    if invalid_auth_token?(conn) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, Jason.encode!(unauthorized_response_body()))
      |> halt
    else
      conn
    end
  end

  # Private functions

  defp invalid_auth_token?(conn) do
    auth_token_from_params(conn) != auth_token()
  end

  defp auth_token_from_params(conn) do
    conn
    |> fetch_query_params()
    |> Map.get(:query_params)
    |> Map.get("auth_token")
  end

  defp auth_token do
    Application.get_env(:evl_daemon, :auth_token)
  end

  defp unauthorized_response_body do
    %{error: "You need to specify a valid authentication token."}
  end
end
