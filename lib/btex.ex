defmodule Btex do
  import Bencode.Decoder
  def read_torrent(filename) do
    iodata = File.read!(filename)
    decode(iodata) |> IO.inspect()
  end
end
