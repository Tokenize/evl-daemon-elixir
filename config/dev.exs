# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.

use Mix.Config

config :logger, level: :debug
config :evl_daemon, EvlDaemon.Mailer, adapter: Bamboo.LocalAdapter
