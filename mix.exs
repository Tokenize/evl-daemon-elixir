defmodule EvlDaemon.Mixfile do
  use Mix.Project

  def project do
    [app: :evl_daemon,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [
        :logger, :plug
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
      { :bamboo, "~> 0.8" },
      { :conform, "~> 2.3.0" },
      { :distillery, "~> 1.2.2"},
      { :httpoison, "~> 0.10.0" },
      { :plug, "~> 1.3.0" },
      { :cowboy, "~> 1.1.2" }
    ]
  end
end
