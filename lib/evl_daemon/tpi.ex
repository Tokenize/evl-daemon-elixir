defmodule EvlDaemon.TPI do
  @moduledoc """
  This module includes the needed functions to encode and decode requests / responses
  from / to the EnvisaLink TPI hardware module.
  """

  use Bitwise

  @doc """
  Takes a binary string and appends the checksum and the EOLs.
  """
  @spec encode(String.t()) :: String.t()
  def encode(string) do
    string <> checksum(string) <> "\r\n"
  end

  @doc """
  Takes a binary string and trims it then validates the checksum.
  """
  @spec decode(String.t()) :: {:ok | :error, String.t()}
  def decode(encoded_string) do
    string = String.trim(encoded_string)

    if valid?(encoded_string), do: {:ok, string}, else: {:error, encoded_string}
  end

  @doc """
  Takes a binary string and validates it using the checksum.
  """
  @spec valid?(String.t()) :: boolean
  def valid?(string) do
    data_bytes_size = byte_size(string) - 4

    <<command_and_data::binary-size(data_bytes_size), cks::binary-size(2), _eols::binary-size(2)>> =
      string

    cks == checksum(command_and_data)
  end

  @doc """
  Takes a binary string and calculates its checksum.
  """
  @spec checksum(String.t()) :: String.t()
  def checksum(string) do
    String.codepoints(string)
    |> Enum.map(fn element -> element |> Base.encode16() end)
    |> Enum.reduce(0, fn element, acc -> String.to_integer(element, 16) + acc end)
    |> Bitwise.band(255)
    |> Integer.to_string(16)
    |> String.pad_leading(2, ["0"])
  end

  @doc """
  Takes a binary string representing a TPI message and returns its command part.
  """
  @spec command_part(String.t()) :: String.t()
  def command_part(string) do
    String.slice(string, 0..2)
  end

  @doc """
  Takes a binary string representing a TPI message and returns its data part.
  """
  @spec data_part(String.t()) :: String.t()
  def data_part(string) do
    String.slice(string, 3..-3)
  end
end
