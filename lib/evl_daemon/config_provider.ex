defmodule EvlDaemon.ConfigProvider do
  @moduledoc """
  This module provides an implementation of Distilery's configuration provider
  behavior, so that JSON files can be used for configuration in releases.
  """

  use Mix.Releases.Config.Provider

  @doc false
  def init([config_path]) do
    # Helper which expands paths to absolute form
    # and expands env vars in the path of the form `${VAR}`
    # to their value in the system environment
    {:ok, config_path} = Provider.expand_path(config_path)
    # All applications are already loaded at this point
    if File.exists?(config_path) do
      config_path
      |> File.read!()
      |> Poison.decode!()
      |> persist()
    else
      :ok
    end
  end

  defp to_keyword(config) when is_map(config) do
    for {k, v} <- config do
      k = String.to_atom(k)
      {k, to_keyword(v)}
    end
  end

  defp to_keyword(config) when is_list(config) do
    config
    |> Enum.map(fn element ->
      to_keyword(element)
    end)
  end

  defp to_keyword(config), do: config

  defp persist(config) when is_map(config) do
    keyworded_config = to_keyword(config)

    for {app, app_config} <- keyworded_config do
      base_config = Application.get_all_env(app)
      merged = merge_config(base_config, app_config)

      for {k, v} <- merged do
        transformed_value = transform(k, v)
        Application.put_env(app, k, transformed_value, persistent: true)
      end
    end

    :ok
  end

  defp merge_config(base, app) when is_list(base) and is_list(app) do
    Keyword.merge(base, app, fn key, base_val, app_val ->
      merge_config(key, base_val, app_val)
    end)
  end

  defp merge_config(_key, val1, val2) when is_list(val1) and is_list(val2) do
    if Keyword.keyword?(val1) and Keyword.keyword?(val2) do
      Keyword.merge(val1, val2, &merge_config/3)
    else
      val2
    end
  end

  defp merge_config(_key, _val1, val2), do: val2

  defp transform(key, value) when key in [:zones, :partitions] do
    value
    |> Enum.into(%{})
  end

  defp transform(_key = :host, value) do
    value
    |> String.to_charlist()
  end

  defp transform(_key = :log_level, value) do
    value
    |> String.to_atom()
  end

  defp transform(_key, value), do: value
end
