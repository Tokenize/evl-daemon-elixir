defmodule EvlDaemon.CLI do
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(args) do
    parse = OptionParser.parse(args, switches: [help: :boolean], aliases: [h: :help])

    case parse do
      {[help: true], _, _}
      -> :help

      {_, [host, password], _}
      -> {String.to_char_list(host), password}

      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: evl_daemon host password
    """

    System.halt(0)
  end

  def process({host, password}) do
    event_dispatcher = EvlDaemon.EventDispatcher.start_link
    opts = %{event_dispatcher: event_dispatcher, hostname: host, password: password}

    {:ok, connection} = EvlDaemon.Connection.start_link(opts)

    EvlDaemon.Connection.connect(connection)
    EvlDaemon.Connection.command(connection, "005#{password}")

    Process.sleep(:infinity)
  end
end
