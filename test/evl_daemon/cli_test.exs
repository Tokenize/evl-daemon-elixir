defmodule CliTest do
  use ExUnit.Case
  doctest EvlDaemon.CLI

  test ":help returned by option parsing --help or -h" do
    assert EvlDaemon.CLI.parse_args(["-h", "anything"]) == :help
    assert EvlDaemon.CLI.parse_args(["--help", "anything"]) == :help
  end

  test ":help returned by passing less than two options" do
    assert EvlDaemon.CLI.parse_args(["10.0.1.1"]) == :help
  end

  test "{host, password} returned by option parsing host & password" do
    assert EvlDaemon.CLI.parse_args(["10.0.1.1", "user"]) == {'10.0.1.1', "user"}
  end
end
