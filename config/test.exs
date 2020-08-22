# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.

import Mix.Config

config :logger, level: :info
config :evl_daemon, EvlDaemon.Mailer, adapter: Bamboo.TestAdapter
config :evl_daemon, api_port: 4001
