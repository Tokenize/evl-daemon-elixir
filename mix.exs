defmodule EvlDaemon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :evl_daemon,
      version: "0.2.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [
        :logger,
      ],
      mod: {EvlDaemon, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:bamboo, "~> 1.2.0"},
      {:distillery, "~> 2.0"},
      {:httpoison, "~> 1.4.0"},
      {:poison, "~> 3.1"},
      {:plug_cowboy, "~> 2.0"},
      {:cors_plug, "~> 1.5"},
    ]
  end
end
