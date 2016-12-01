defmodule EvlDaemon.TPITest do
  use ExUnit.Case
  doctest EvlDaemon.TPI

  test "request encoding is correct" do
    assert EvlDaemon.TPI.encode("005user") == "005user54\r\n"
  end

  test "valid-response decoding is correct" do
    assert EvlDaemon.TPI.decode("005SecretFB\r\n") == {:ok, "005SecretFB"}
  end

  test "invalid-response decoding is correct" do
    assert EvlDaemon.TPI.decode("0056Secret34\r\n") == {:error, "0056Secret34\r\n"}
  end

  test "correctly identifies valid commands" do
    assert EvlDaemon.TPI.valid?("005user54\r\n")
  end

  test "checksum is correct" do
    assert EvlDaemon.TPI.checksum("6543") == "D2"
  end

  test "checksum is truncated to 1 byte" do
    assert EvlDaemon.TPI.checksum("005123456") == "CA"
  end

  test "checksum gets a leading zero if needed" do
    assert EvlDaemon.TPI.checksum("5108A") == "0F"
  end

  test "command_part returns the correct part" do
    assert EvlDaemon.TPI.command_part("005user54") == "005"
  end

  test "data_part returns the correct part" do
    assert EvlDaemon.TPI.data_part("005user54") == "user"
  end
end
