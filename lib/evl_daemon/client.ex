defmodule EvlDaemon.Client do
  use GenServer

  defdelegate connect, to: EvlDaemon.Connection

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def login(password) do
    GenServer.call(__MODULE__, {:login, password})
  end

  def status_report do
    GenServer.cast(__MODULE__, :status_report)
  end

  def handle_call({:login, password}, _sender, state) do
    status = EvlDaemon.Connection.command("005#{password}")

    {:reply, status, state}
  end

  def handle_cast(:status_report, state) do
    EvlDaemon.Connection.command("001")

    {:noreply, state}
  end
end
