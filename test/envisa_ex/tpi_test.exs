defmodule EnvisaEx.TPITest do
  use ExUnit.Case
  doctest EnvisaEx.TPI

  test "request encoding is correct" do
    assert EnvisaEx.TPI.encode("0056Secret") == "3030353653656372657433330D0A"
  end

  test "valid-response decoding is correct" do
    assert EnvisaEx.TPI.decode("0056Secret33\r\n") == {:ok, "0056Secret33"}
  end

  test "invalid-response decoding is correct" do
    assert EnvisaEx.TPI.decode("0056Secret34\r\n") == {:error, "0056Secret34\r\n"}
  end

  test "correctly identifies valid commands" do
    assert EnvisaEx.TPI.valid?("0056Secret33\r\n")
  end

  test "checksum is correct" do
    assert EnvisaEx.TPI.checksum("6543") == "D2"
  end

  test "checksum is truncated to 1 byte" do
    assert EnvisaEx.TPI.checksum("0056Secret") == "33"
  end
end
