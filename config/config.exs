use Mix.Config

import_config "#{Mix.env()}.exs"

config :evl_daemon, host: '127.0.0.1'
config :evl_daemon, port: 4025
config :evl_daemon, password: "SECRET"
config :evl_daemon, auto_connect: false
config :evl_daemon, event_notifiers: []
config :evl_daemon, storage_engines: []
config :evl_daemon, tasks: []
config :evl_daemon, zones: %{}
config :evl_daemon, partitions: %{}
config :evl_daemon, system_emails_sender: "noreply@example.com"
config :evl_daemon, system_emails_recipient: "user@example.com"
config :evl_daemon, auth_token: "SECRET"
config :pid_file, file: "/tmp/evl_daemon.pid"
