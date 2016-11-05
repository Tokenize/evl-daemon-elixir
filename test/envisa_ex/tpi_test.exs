defmodule EnvisaEx.TPITest do
  use ExUnit.Case
  doctest EnvisaEx.TPI

  test "request encoding is correct" do
    assert EnvisaEx.TPI.encode("005user") == "005user54\r\n"
  end

  test "valid-response decoding is correct" do
    assert EnvisaEx.TPI.decode("005SecretFB\r\n") == {:ok, "005SecretFB"}
  end

  test "invalid-response decoding is correct" do
    assert EnvisaEx.TPI.decode("0056Secret34\r\n") == {:error, "0056Secret34\r\n"}
  end

  test "correctly identifies valid commands" do
    assert EnvisaEx.TPI.valid?("005user54\r\n")
  end

  test "checksum is correct" do
    assert EnvisaEx.TPI.checksum("6543") == "D2"
  end

  test "checksum is truncated to 1 byte" do
    assert EnvisaEx.TPI.checksum("005123456") == "CA"
  end

  test "command_part returns the correct part" do
    assert EnvisaEx.TPI.command_part("005user54") == "005"
  end

  test "data_part returns the correct part" do
    assert EnvisaEx.TPI.data_part("005user54") == "user"
  end
end
