defmodule EvlDaemon.Client do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts, 0}
  end

  def connect do
    GenServer.call(__MODULE__, :connect)
  end

  def login do
    GenServer.call(__MODULE__, :login)
  end

  def status_report do
    GenServer.cast(__MODULE__, :status_report)
  end

  def handle_call(:connect, _sender, state) do
    status = do_connect

    {:reply, status, state}
  end

  def handle_call(:login, _sender, state) do
    status = do_login(state.password)

    {:reply, status, state}
  end

  def handle_cast(:status_report, state) do
    EvlDaemon.Connection.command("001")

    {:noreply, state}
  end

  def handle_info(:timeout, state) do
    do_connect
    do_login(state.password)

    {:noreply, state}
  end

  defp do_connect do
    EvlDaemon.Connection.connect
  end

  defp do_login(password) do
    EvlDaemon.Connection.command("005#{password}")
  end
end
