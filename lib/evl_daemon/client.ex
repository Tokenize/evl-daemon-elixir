defmodule EvlDaemon.Client do
  @moduledoc """
  This module abstracts the details of sending commands to the EVL by providing
  convenience functions such as connect / login / status_report...etc.
  """

  use GenServer
  use EvlDaemon.ErrorNotifier
  alias EvlDaemon.Connection

  @poll_interval 60000

  def child_spec(opts) do
    %{id: __MODULE__, restart: :permanent, start: {__MODULE__, :start_link, opts}, type: :worker}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    if Application.get_env(:evl_daemon, :auto_connect) do
      {:ok, opts, {:continue, :auto_connect}}
    else
      {:ok, opts}
    end
  end

  @doc """
  Connect to host:port by delegating the call to Connection.connect.
  """
  def connect do
    GenServer.call(__MODULE__, :connect)
  end

  @doc """
  Send the login command and wait for acknowledgment.
  """
  def login do
    GenServer.call(__MODULE__, :login)
  end

  @doc """
  Send the status report command and do not wait for acknowledgment.
  """
  def status_report do
    GenServer.cast(__MODULE__, :status_report)
  end

  @doc """
  Send the poll command to keep the connection alive.
  """
  def poll do
    GenServer.cast(__MODULE__, :poll)
  end

  # Callbacks

  def handle_call(:connect, _sender, state) do
    status = do_connect()

    {:reply, status, state}
  end

  def handle_call(:login, _sender, state) do
    status = do_login()

    {:reply, status, state}
  end

  def handle_cast(:status_report, state) do
    Connection.command("001")

    {:noreply, state}
  end

  def handle_cast(:poll, state) do
    do_poll()

    {:noreply, state, @poll_interval}
  end

  def handle_continue(:auto_connect, state) do
    if Connection.alive?() do
      do_poll()
    else
      do_connect()
      do_login()
    end

    {:noreply, state, @poll_interval}
  end

  # Private functions

  defp do_connect do
    Connection.connect()
  end

  defp do_login do
    password = Application.get_env(:evl_daemon, :password)
    Connection.command("005#{password}")
  end

  defp do_poll do
    Connection.command("000")
  end
end
