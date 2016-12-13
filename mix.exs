defmodule EvlDaemon.Mixfile do
  use Mix.Project

  def project do
    [app: :evl_daemon,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: escript_config,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :logger, :distillery, :conform, :gen_stage, :sendgrid
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
      { :gen_stage, "~> 0.9.0" },
      { :sendgrid, "~> 1.3.0" },
      { :conform, github: "bitwalker/conform", override: true },
      { :distillery, github: "bitwalker/distillery", override: true }
    ]
  end

  defp escript_config do
    [main_module: EvlDaemon.CLI]
  end
end
