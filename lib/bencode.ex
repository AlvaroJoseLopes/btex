defmodule Bencode do
  @moduledoc """
  Bencoding encoder and decoder.

  See:

  - http://www.bittorrent.org/beps/bep_0003.html#bencoding
  - https://wiki.theory.org/BitTorrentSpecification#Bencoding
  """
  @digits '0123456789'

  @doc """
  Decode a bencoded value.

      iex> Bencode.decode("li1e3:twoli3eee")
      {:ok, [1, "two", [3]]}

  """
  def decode(iodata) do
    {result, rest} = iodata |> IO.iodata_to_binary() |> parse()
    case rest do
      "" -> {:ok, result}
      _ -> {:err, rest}
    end
  end

  # Bencode starting points
  defp parse("l" <> rest), do: parse_list(rest, [])
  defp parse("i" <> rest), do: parse_integer(rest, [])
  defp parse("d" <> rest), do: parse_dictionary(rest, %{})
  defp parse(<<d>> <> _ = str) when d in @digits do
    parse_string(str)
  end

  # Parsing string
  ## Getting string length
  defp parse_string(str) do
    {:ok, length, rest} = get_string_length(str, [])
    get_string_content(length, rest)
  end
  defp get_string_length(<<d>> <> rest, acc) when d in @digits do
    get_string_length(rest, [d | acc])
  end
  defp get_string_length(":" <> rest, acc), do: {:ok, acc |> Enum.reverse() |> List.to_integer, rest}
  defp get_string_length(other, acc), do: {:err, other, acc}
  ## Getting string content
  defp get_string_content(0, str), do: {"", str}
  defp get_string_content(length, str) do
    <<content::binary-size(length)>> <> rest = str
    {content, rest}
  end

  # Parsing integer
  defp parse_integer("-e" <> rest, _acc), do: {:err, rest}
  defp parse_integer("-0" <> rest, _acc), do: {:err, rest}
  defp parse_integer("0e" <> rest, _acc), do: {0, rest}
  defp parse_integer(<<n>> <> rest, acc) when n in @digits do
    parse_integer(rest, [n | acc])
  end
  defp parse_integer("e" <> rest, acc) do
    {acc |> Enum.reverse() |> List.to_integer(), rest}
  end
  defp parse_integer(other, _acc), do: {:err, other}

  # Parsing list
  defp parse_list("e" <> rest, acc), do: {acc |> Enum.reverse(), rest}
  defp parse_list(iodata, acc) do
    {result, rest} = parse(iodata)
    acc = [result | acc]
    parse_list(rest, acc)
  end

  # Parsing Dictionary
  defp parse_dictionary("e" <> rest, acc), do: {acc, rest}
  defp parse_dictionary(iodata, acc) do
    {key, rest}   = parse_string(iodata)
    {value, rest} = parse(rest)
    parse_dictionary(rest, Map.put(acc, key, value))
  end
end
