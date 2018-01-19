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
      storage_engines: configured_storage_engines(),
      tasks: configured_tasks(),
      partition_statuses: partition_statuses(),
      zone_statuses: zone_statuses(),
      node_uptime: node_uptime()
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
      alive?: EvlDaemon.Connection.alive?(),
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

  defp node_uptime do
    {uptime, _time_since_last_call} = :erlang.statistics(:wall_clock)

    {formatted_uptime, unit} =
      case uptime / 1000 do
        seconds when seconds <= 60 -> {seconds, "seconds"}
        seconds when seconds > 60 and seconds <= 3600 -> {seconds / 60, "minutes"}
        seconds when seconds > 3600 and seconds <= 86400 -> {seconds / 3600, "hours"}
        seconds -> {seconds / 86400, "days"}
      end

    "#{formatted_uptime |> Float.round(2)} #{unit}."
  end

  defp get_status_report(key) do
    pid = GenServer.whereis(EvlDaemon.Task.StatusReport)

    case pid do
      nil -> %{"NA" => "StatusReport task is not running!"}
      _ -> EvlDaemon.Task.StatusReport.status() |> Map.get(key)
    end
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
end
