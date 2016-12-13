defmodule EvlDaemon do
  use Application

  def start(_type, _args) do
    EvlDaemon.Supervisor.start_link(%{event_dispatcher: nil})
  end
end
