# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.

import Config

config :logger, level: :info
config :evl_daemon, EvlDaemon.Mailer, adapter: Bamboo.SendGridAdapter, api_key: "SECRET"
