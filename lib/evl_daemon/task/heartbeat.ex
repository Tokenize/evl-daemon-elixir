defmodule EvlDaemon.Task.Heartbeat do
  @moduledoc """
  This module sends a heartbeat to Mimir periodically for a specific
  user and device.
  """

  use GenServer

  @default_interval 10_000

  @doc false
  def child_spec(opts) do
    %{id: __MODULE__, restart: :permanent, start: {__MODULE__, :start_link, opts}, type: :worker}
  end

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    opts
    |> filter_options()
    |> case do
      {:ok, state} ->
        {:ok, state, {:continue, :send_heartbeat}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @doc "Return the timestamp of the latest heartbeat."
  def latest_sent_at do
    GenServer.call(__MODULE__, :latest_sent_at)
  end

  # Genserver Callbacks

  @impl GenServer
  def handle_continue(:send_heartbeat, state) do
    state = do_send_heartbeat(state)

    {:noreply, state, heartbeat_interval(state)}
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    state = do_send_heartbeat(state)

    {:noreply, state, heartbeat_interval(state)}
  end

  @impl GenServer
  def handle_call(:latest_sent_at, _sender, state) do
    {:reply, Keyword.get(state, :latest_sent_at, nil), state}
  end

  # Private functions

  @doc false
  defp do_send_heartbeat(opts) do
    HTTPoison.put!(service_url(opts), body(opts), headers())

    opts
    |> Keyword.put(:latest_sent_at, Time.utc_now())
  end

  @doc false
  defp service_url(opts) do
    host = opts |> Keyword.get(:host)
    device = opts |> Keyword.get(:device)

    host <> "/api/devices/" <> device
  end

  @doc false
  defp headers() do
    [{"Content-Type", "application/json"}, {"Accept", "application/json"}]
  end

  @doc false
  defp body(opts) do
    %{
      auth_token: Keyword.fetch!(opts, :auth_token),
      device: Keyword.fetch!(opts, :device)
    }
    |> Jason.encode!()
  end

  @doc false
  defp filter_options(opts) do
    with {:ok, host} <- Keyword.fetch(opts, :host),
         {:ok, device} <- Keyword.fetch(opts, :device),
         {:ok, auth_token} <- Keyword.fetch(opts, :auth_token),
         interval <- Keyword.get(opts, :interval, @default_interval) do
      {:ok, [host: host, device: device, auth_token: auth_token, interval: interval]}
    else
      _ -> {:error, "invalid options"}
    end
  end

  @doc false
  defp heartbeat_interval(state) do
    Keyword.fetch!(state, :interval)
  end
end
