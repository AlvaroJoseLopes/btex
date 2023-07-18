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

    {:ok, torrent_data}
  end
end
