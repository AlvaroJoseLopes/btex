defmodule Btex do
  @moduledoc """
  Bit Torrent Client.
  """
  def download(filename) do
    IO.puts("Parsing .torrent file ...")
    {:ok, torrent} = Torrent.from_file(filename)
    peer = Peer.new()

    IO.puts("Requesting peers from Tracker ...")
    {:ok, response} = Tracker.request(torrent, peer)

    n_pieces = length(torrent["info"]["pieces"])
    IO.puts("Number of pieces to be downloaded #{n_pieces}")

    IO.puts("Connecting to peers (#{length(response["peers"])}) to request pieces ...")
    Peer2Peer.request_pieces(torrent, peer, response["peers"])
  end

  def test do
    # download("torrent/ComputerNetworks.torrent")
    download("torrent/MoralPsychHandbook.torrent")
  end
end
