use Mix.Config

import_config "#{Mix.env}.exs"

config :distillery, no_warn_missing: [:plug]

config :evl_daemon, host: '127.0.0.1'
config :evl_daemon, port: 4025
config :evl_daemon, password: "SECRET"
config :evl_daemon, auto_connect: false
config :evl_daemon, event_notifiers: [
  [type: :console],
  [type: :email, recipient: "user@example.com", sender: "noreply@example.com"],
  [type: :sms, from: "+1234567890", to: "+10987654321", sid: "SID", auth_token: "SECRET"]
]
config :evl_daemon, zones: %{}
