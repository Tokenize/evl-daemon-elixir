defmodule EvlDaemon.Connection do
  @moduledoc """
  This module wraps a TCP connection and handles connecting, disconnecting, sending and receiving of commands
  to the EVL module.
  """

  use GenServer
  require Logger

  @initial_state %{socket: nil, event_dispatcher: nil, pending_commands: %{}, hostname: nil, port: 4025, password: nil}

  def start_link(state \\ @initial_state) do
    GenServer.start_link(__MODULE__, Map.merge(@initial_state, state), name: __MODULE__)
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
    GenServer.call(__MODULE__, { :command, request })
  end

  # Callbacks

  def handle_call(:connect, _sender, state) do
    Logger.debug "Connecting..."

    opts = [:binary, active: true, packet: :line]
    {:ok, socket} = :gen_tcp.connect(state.hostname, state.port, opts)
    new_state = %{state | socket: socket}

    {:reply, :ok, new_state}
  end

  def handle_call({:command, payload}, sender, state) do
    Logger.debug(fn -> "Sending [#{inspect payload}]" end)

    :ok = :gen_tcp.send(state.socket, EvlDaemon.TPI.encode(payload))

    cmd = EvlDaemon.TPI.command_part(payload)
    pending_commands = Map.put(state.pending_commands, cmd, sender)
    state = %{state | pending_commands: pending_commands}

    {:noreply, state}
  end

  def handle_cast(:disconnect, state) do
    Logger.debug "Disconnecting..."

    {:noreply, :gen_tcp.close(state.socket)}
  end

  def handle_info({:tcp, socket, "500" <> payload}, %{socket: socket} = state) do
    Logger.debug "Receiving acknowledgment for [#{inspect payload}]"

    cmd = EvlDaemon.TPI.command_part(payload)
    {client, pending_commands} = Map.pop(state.pending_commands, cmd)

    GenServer.reply(client, :ok)

    state = %{state | pending_commands: pending_commands}
    {:noreply, state}
  end

  def handle_info({:tcp, socket, msg}, %{socket: socket} = state) do
    {:ok, decoded_message} = EvlDaemon.TPI.decode(msg)

    Logger.debug(fn -> "Receiving [#{inspect msg}] (#{EvlDaemon.Event.description(decoded_message)})" end)
    EvlDaemon.EventDispatcher.enqueue(state.event_dispatcher, decoded_message)

    {:noreply, state}
  end
end
