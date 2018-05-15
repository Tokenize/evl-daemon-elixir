defmodule EvlDaemon.Router do
  use Plug.Router

  plug(Plug.Logger, log: :debug)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug CORSPlug, origin: "*", methods: ["GET", "DELETE"]
  plug(EvlDaemon.Plug.AuthTokenValidator)
  plug(EvlDaemon.Plug.Events)
  plug(EvlDaemon.Plug.Tasks)
  plug(EvlDaemon.Plug.SystemStatus)
  plug(:match)
  plug(:dispatch)

  def child_spec(opts) do
    %{id: __MODULE__, restart: :permanent, start: {__MODULE__, :start_link, opts}, type: :worker}
  end

  def start_link(opts \\ []) do
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, opts, port: port_number())
  end

  match _ do
    send_resp(conn, :not_found, "endpoint invalid.")
  end

  # Private functions

  defp port_number do
    Application.get_env(:evl_daemon, :api_port, 4000)
  end
end
