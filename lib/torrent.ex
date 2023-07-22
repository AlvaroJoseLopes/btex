defmodule Torrent do
  @moduledoc """
  Handles torrent file.
  """
  import Bencode.Encoder
  import Bencode.Decoder

  @doc """
  Get torrent info from .torrent file.
  Returns torrent data into a Map.
  """
  def from_file(filename) do
    {:ok, torrent_data} = File.read!(filename) |> decode()
    info_hash = :crypto.hash(:sha, torrent_data["info"] |> encode())
    torrent_data = Map.put(torrent_data, "info_hash", info_hash)

    pieces = torrent_data["info"]["pieces"] |> chunk()
    torrent_data = put_in(torrent_data, ["info", "pieces"], pieces)
    {:ok, torrent_data}
  end

  defp chunk(pieces) do
    case pieces |> Kernel.byte_size() |> Kernel.rem(20) do
      0 -> do_chunk(pieces, 20, [])
      _ -> {:err, "Pieces blob must be multiple of 20 bytes"}
    end
  end

  defp do_chunk(<<>>, _, acc), do: acc

  defp do_chunk(bin, chunk_size, acc) do
    <<chunk::binary-size(chunk_size), rest::bitstring>> = bin
    do_chunk(rest, chunk_size, [<<chunk::binary-size(chunk_size)>> | acc])
  end
end
