defmodule EvlDaemon.Connection do
  @moduledoc """
  This module wraps a TCP connection and handles connecting, disconnecting, sending and receiving of commands
  to the EVL module.
  """

  use GenServer
  use EvlDaemon.ErrorNotifier
  require Logger
  alias EvlDaemon.{Event, EventDispatcher, TPI}

  @initial_state %{socket: nil, pending_commands: %{}}

  def child_spec(opts) do
    %{id: __MODULE__, restart: :permanent, start: {__MODULE__, :start_link, opts}, type: :worker}
  end

  def start_link(state \\ @initial_state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, Map.merge(@initial_state, state)}
  end

  @doc """
  Connect to host:port (as specified in the hash of opts passed to start_link).
  """
  def connect do
    GenServer.call(__MODULE__, :connect)
  end

  @doc """
  Disconnect from host:port (as specified in the hash of opts passed to start_link).
  """
  def disconnect do
    GenServer.cast(__MODULE__, :disconnect)
  end

  @doc """
  Send the request to the destination host. This command will be encoded by calling TPI.encode before
  sending it.
  """
  def command(request) do
    GenServer.call(__MODULE__, {:command, request})
  end

  @doc """
  Check if the connection is alive by checking the underlying socket."
  """
  def alive? do
    GenServer.call(__MODULE__, :alive?)
  end

  # Callbacks

  def handle_call(:connect, sender, state) do
    host = Application.get_env(:evl_daemon, :host)
    port = Application.get_env(:evl_daemon, :port)

    Logger.debug("Connecting to #{host}:#{port}...")

    opts = [:binary, active: true, packet: :line]
    {:ok, socket} = :gen_tcp.connect(host, port, opts)

    pending_commands = push_pending_command(state.pending_commands, "5053", sender)
    new_state = %{state | socket: socket, pending_commands: pending_commands}

    {:noreply, new_state}
  end

  def handle_call({:command, payload}, sender, state) do
    Logger.debug(fn -> "Sending [#{inspect(payload)}]" end)

    :ok = :gen_tcp.send(state.socket, TPI.encode(payload))

    pending_commands = push_pending_command(state.pending_commands, payload, sender)
    state = %{state | pending_commands: pending_commands}

    {:noreply, state}
  end

  def handle_call(:alive?, _sender, state) do
    {status, _stats} =
      case state.socket do
        nil -> {:error, nil}
        socket -> :inet.getstat(socket)
      end

    {:reply, status == :ok, state}
  end

  def handle_cast(:disconnect, state) do
    Logger.debug("Disconnecting...")

    :ok = :gen_tcp.close(state.socket)

    {:noreply, %{state | socket: nil}}
  end

  def handle_info({:tcp, socket, "5053" <> _trailer}, %{socket: socket} = state) do
    Logger.debug("Receiving Login Interaction Password request")

    {client, pending_commands} = pop_pending_command(state.pending_commands, "5053")

    GenServer.reply(client, :ok)

    state = %{state | pending_commands: pending_commands}
    {:noreply, state}
  end

  def handle_info({:tcp, socket, "500" <> payload}, %{socket: socket} = state) do
    Logger.debug("Receiving acknowledgment for [#{inspect(payload)}]")

    {client, pending_commands} = pop_pending_command(state.pending_commands, payload)

    GenServer.reply(client, :ok)

    state = %{state | pending_commands: pending_commands}
    {:noreply, state}
  end

  def handle_info({:tcp, socket, msg}, %{socket: socket} = state) do
    {:ok, decoded_message} = TPI.decode(msg)

    Logger.debug(fn ->
      description = Event.description(decoded_message)
      "Receiving [#{inspect(msg)}] (#{description.command}:#{description.data})"
    end)

    EventDispatcher.enqueue(decoded_message)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.error("#{__MODULE__} TCP socket closed. Terminating process #{inspect(self())}.")

    {:stop, :connection_closed, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  # Private functions

  defp push_pending_command(pending_commands, payload, sender) do
    pending_commands
    |> Map.put(TPI.command_part(payload), sender)
  end

  defp pop_pending_command(pending_commands, payload) do
    pending_commands
    |> Map.pop(TPI.command_part(payload))
  end
end
