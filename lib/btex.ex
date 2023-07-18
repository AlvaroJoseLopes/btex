defmodule Btex do
  @moduledoc """
  Bit Torrent Client.
  """
  def download(filename) do
    IO.puts("Parsing .torrent file ...")
    {:ok, torrent} = Torrent.from_file(filename)
    peer = Peer.new()

    IO.puts("Requesting peers for Tracker ...")
    {:ok, reponse} = Tracker.request(torrent, peer)
    reponse
  end

  def test() do
    # download("torrent/ComputerNetworks.torrent")
    download("torrent/MoralPsychHandbook.torrent")
  end
end
