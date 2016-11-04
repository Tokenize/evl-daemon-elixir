defmodule EnvisaEx.Connection do
  use GenServer

  @initial_state %{socket: nil, events_queue: nil, pending_commands: %{}, hostname: nil, port: 4025, password: nil}

  def start_link(state \\ @initial_state) do
    GenServer.start_link(__MODULE__, Map.merge(@initial_state, state))
  end

  def connect(pid) do
    GenServer.call(pid, :connect)
  end

  def disconnect(pid) do
    GenServer.cast(pid, :disconnect)
  end

  def command(pid, request) do
    GenServer.call(pid, { :command, request })
  end

  def handle_call(:connect, _sender, state) do
    opts = [:binary, active: true, packet: :line]
    {:ok, socket} = :gen_tcp.connect(state.hostname, state.port, opts)
    new_state = %{state | socket: socket}

    {:reply, :ok, new_state}
  end

  def handle_call({:command, payload}, sender, state) do
    :ok = :gen_tcp.send(state.socket, EnvisaEx.TPI.encode(payload))

    pending_commands = Map.put(state.pending_commands, String.slice(payload, 0..2), sender)
    state = %{state | pending_commands: pending_commands}

    {:noreply, state}
  end

  def handle_cast(:disconnect, state) do
    {:noreply, :gen_tcp.close(state.socket)}
  end

  def handle_info({:tcp, socket, "500" <> payload}, %{socket: socket} = state) do
    cmd = String.slice(payload, 0..2)
    {client, pending_commands} = Map.pop(state.pending_commands, cmd)

    GenServer.reply(client, :ok)

    state = %{state | pending_commands: pending_commands}
    {:noreply, state}
  end

  def handle_info({:tcp, socket, msg}, %{socket: socket} = state) do
    decoded = EnvisaEx.TPI.decode(msg)

    state = %{state | events_queue: state.events_queue.push(decoded_message)}

    {:noreply, state}
  end
end
