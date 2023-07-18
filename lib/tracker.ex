defmodule Tracker do
  @moduledoc """
  Tracker module.
  """
  @timeout 50_000

  @doc """
  Request a tracker for info about Peers related to the torrent data.
  """
  def request(torrent, peer) do
    url = get_request_url(torrent, peer)

    case HTTPoison.get(url, [], [follow_redirect: true, recv_timeout: @timeout]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body |> Bencode.Decoder.decode()
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        raise "Tracker: 404 error"
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise "TrackerError #{reason}"
    end

  end

  defp get_request_url(torrent, peer) do
    query = %{
      "info_hash"   => torrent["info_hash"],
      "peer_id"     => peer[:id],
      "port"        => peer[:port],
      "uploaded"    => peer[:uploaded],
      "downloaded"  => peer[:downloaded],
      "left"        => torrent["info"]["length"] - peer[:downloaded],
      "compact"     => peer["compact"]
    } |> URI.encode_query()

    torrent["announce"] <> "?" <> query
  end
end
