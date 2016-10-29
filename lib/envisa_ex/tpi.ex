defmodule EnvisaEx.TPI do
  @moduledoc """
  This module includes the needed functions to encode and decode requests / responses
  from / to the EnvisaLink TPI hardware module.
  """

  @doc """
  Takes a binary string and encodes it into base16 then appends the checksum and the EOLs.
  """
  def encode(string) do
    string <> checksum(string) <> "\r\n"
    |> Base.encode16
  end

  @doc """
  Takes a binary string and trims it then validates the checksum.
  """
  def decode(encoded_string) do
    string = String.trim(encoded_string)

    if valid?(encoded_string), do: {:ok, string}, else: {:error, encoded_string}
  end

  @doc """
  Takes a binary string and validates it using the checksum.
  """
  def valid?(string) do
    data_bytes_size = byte_size(string) - 4

    <<command_and_data::binary-size(data_bytes_size), cks::binary-size(2), _eols::binary-size(2)>> = string

    cks == checksum(command_and_data)
  end

  @doc """
  Takes a binary string and calculates its checksum.
  """
  def checksum(string) do
    String.codepoints(string)
    |> Enum.map(fn element -> element |> Base.encode16 end)
    |> Enum.reduce(0, fn element, acc -> String.to_integer(element, 16) + acc end)
    |> Integer.to_string(16)
    |> binary_part(0, 2)
  end
end
