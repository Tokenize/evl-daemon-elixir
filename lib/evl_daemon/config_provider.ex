defmodule EvlDaemon.ConfigProvider do
  @moduledoc """
  This module provides an implementation of Elixir's configuration provider
  behavior, so that JSON files can be used for configuration in releases.
  """

  @behaviour Config.Provider

  @supported_config_keys [
    :host,
    :port,
    :mailer_api_key,
    :password,
    :auto_connect,
    :event_notifiers,
    :storage_engines,
    :tasks,
    :zones,
    :partitions,
    :system_emails_sender,
    :system_emails_recipient,
    :log_level,
    :auth_token
  ]

  @doc false
  def init(path) when is_binary(path) or is_list(path), do: path

  def load(config, path) do
    {:ok, _} = Application.ensure_all_started(:jason)

    custom_config =
      path
      |> resolve_config_file_path()
      |> File.read!()
      |> Jason.decode!(keys: :atoms)
      |> parse_config()

    Config.Reader.merge(config, evl_daemon: custom_config)
  end

  @doc false
  defp parse_config(json_config) do
    json_config
    |> Map.get(:evl_daemon, %{})
    |> Map.take(@supported_config_keys)
    |> Enum.map(fn {key, value} -> parse_config_entry(key, value) end)
  end

  @doc false
  defp parse_config_entry(key = :host, value), do: {key, value |> String.to_charlist()}
  defp parse_config_entry(key = :log_level, value), do: {key, value |> String.to_atom()}

  defp parse_config_entry(_key = :mailer_api_key, value) do
    adapter = Application.get_env(:evl_daemon, EvlDaemon.Mailer) |> Keyword.get(:adapter)
    {EvlDaemon.Mailer, [adapter: adapter, api_key: value]}
  end

  defp parse_config_entry(key, value) when key in [:zones, :partitions] do
    stringified_map =
      value
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
      |> Enum.into(%{})

    {key, stringified_map}
  end

  defp parse_config_entry(key, value) when key in [:event_notifiers, :tasks, :storage_engines] do
    {key, value |> Enum.map(fn x -> Map.to_list(x) end)}
  end

  defp parse_config_entry(key, value), do: {key, value}

  @doc false
  defp resolve_config_file_path(path) when is_binary(path), do: path

  defp resolve_config_file_path(paths) when is_list(paths) do
    local_config = paths |> Enum.find(fn path -> String.starts_with?(path, "~") end)
    global_config = paths |> Enum.find(fn path -> path != local_config end)
    expanded_local_config = local_config |> Path.expand()

    cond do
      File.exists?(expanded_local_config) ->
        expanded_local_config

      true ->
        global_config
    end
  end
end
