defmodule EvlDaemon.Plug.SystemStatus do
  import Plug.Conn
  alias EvlDaemon.{Connection, Task}

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
      armed_state: armed_state(),
      connection: configured_connection(),
      last_event: latest_event(),
      listeners: configured_listeners(),
      notifiers: configured_event_notifiers(),
      partitions: partitions(),
      statuses: %{
        zones: zone_statuses(),
        partitions: partition_statuses()
      },
      storage: configured_storage_engines(),
      tasks: configured_tasks(),
      uptime: node_uptime(),
      zones: zones()
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
      alive?: Connection.alive?(),
      host: Application.get_env(:evl_daemon, :host) |> to_string,
      port: Application.get_env(:evl_daemon, :port)
    }
  end

  defp configured_tasks do
    Application.get_env(:evl_daemon, :tasks, [])
    |> Enum.map(fn task ->
      Keyword.get(task, :type)
    end)
  end

  defp configured_listeners do
    [
      :http
    ]
  end

  defp node_uptime do
    {uptime, _time_since_last_call} = :erlang.statistics(:wall_clock)
    uptime / 1000
  end

  defp get_status_report(key) do
    pid = GenServer.whereis(EvlDaemon.Task.StatusReport)

    case pid do
      nil -> %{"NA" => "StatusReport task is not running!"}
      _ -> Task.StatusReport.status() |> Map.get(key)
    end
  end

  def armed_state do
    :armed_states
    |> get_status_report()
    |> Enum.map(fn {partition, description} ->
      %{partition: partition, state: description}
    end)
  end

  def partition_statuses do
    :partitions
    |> get_status_report()
    |> Enum.reduce(%{}, fn {partition, description}, statuses ->
      Map.merge(statuses, %{partition => description})
    end)
  end

  def zone_statuses do
    :zones
    |> get_status_report()
    |> Enum.reduce(%{}, fn {zone, description}, statuses ->
      Map.merge(statuses, %{zone => description})
    end)
  end

  defp zones do
    Application.get_env(:evl_daemon, :zones)
    |> Enum.map(fn {zone, name} ->
      %{number: zone, name: name}
    end)
  end

  defp partitions do
    Application.get_env(:evl_daemon, :partitions)
    |> Enum.map(fn {zone, name} ->
      %{number: zone, name: name}
    end)
  end

  defp latest_event do
    :latest_event |> get_status_report()
  end
end
