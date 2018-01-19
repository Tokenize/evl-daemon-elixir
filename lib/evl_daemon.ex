defmodule EvlDaemon do
  require Logger
  use Application

  @version Mix.Project.config()[:version]

  def start(_type, _args) do
    Logger.info("Starting EvlDaemon v#{@version}")
    EvlDaemon.Email.Application.starting(@version) |> EvlDaemon.Mailer.deliver_later()

    EvlDaemon.Supervisor.start_link()
  end

  def stop(_state) do
    Logger.info("Stopping EvlDaemon v#{@version}")
    EvlDaemon.Email.Application.stopping(@version) |> EvlDaemon.Mailer.deliver_now()
  end
end
