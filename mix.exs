defmodule EvlDaemon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :evl_daemon,
      version: "0.4.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "EvlDaemon",
      source_url: "https://github.com/Tokenize/evl-daemon-elixir",
      homepage_url: "https://github.com/Tokenize/evl-daemon-elixir",
      docs: [
        main: "EvlDaemon",
        extras: ["README.md"]
      ],
      description: description(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      deps: deps(),
      package: package(),
      releases: releases()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [
        :logger
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
      {:httpoison, "~> 1.7.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:cors_plug, "~> 1.5"},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.22.2", only: [:dev], runtime: false},
      {:bypass, "~> 1.0", only: [:test]}
    ]
  end

  defp description do
    "An Elixir based daemon for Envisalink EVL modules."
  end

  defp package do
    [
      maintainers: ["Zaid Al-Jarrah"],
      licenses: ["GPL 3.0"],
      links: %{"GitHub" => "https://github.com/Tokenize/evl-daemon-elixir"}
    ]
  end

  defp releases do
    [
      evl_daemon: [
        config_providers: [
          {
            EvlDaemon.ConfigProvider,
            [
              "/etc/evl_daemon.json",
              "~/.config/evl_daemon/config.json"
            ]
          }
        ],
        applications: [evl_daemon: :permanent],
        include_erts: false
      ]
    ]
  end
end
