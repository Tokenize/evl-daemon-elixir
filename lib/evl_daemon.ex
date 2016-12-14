defmodule EvlDaemon do
  require Logger
  use Application

  @version Mix.Project.config[:version]

  def start(_type, _args) do
    Logger.info "Starting EvlDaemon v#{@version}"

    EvlDaemon.Supervisor.start_link(%{event_dispatcher: nil})
  end
end
