use Mix.Config

import_config "#{Mix.env}.exs"

config :evl_daemon, host: '127.0.0.1'
config :evl_daemon, port: 4025
config :evl_daemon, password: "SECRET"
config :evl_daemon, auto_connect: false
config :evl_daemon, event_notifiers: []
config :evl_daemon, zones: %{}
config :evl_daemon, system_emails_sender: "noreply@example.com"
config :evl_daemon, system_emails_recipient: "user@example.com"
