defmodule Peer2Peer do
  @timeout 50_000

  def request_pieces(torrent_info, client, peers) do
    info_hash = torrent_info["info_hash"]

    peers
    |> Task.async_stream(fn p -> connect_tcp(p, client, info_hash) end, timeout: @timeout)
    |> Enum.to_list()
    |> Enum.filter(fn {key, _} -> key == :ok end)
    |> Enum.filter(fn {_, {_, response}} -> response[:info_hash] == info_hash end)
    |> IO.inspect()
    |> Enum.map(fn {_, {socket, _}} -> Socket.close(socket) end)
  end

  defp connect_tcp(peer, client, info_hash) do
    IO.puts("handshaking with #{peer["ip"]}:#{peer["port"]}")

    case Socket.TCP.connect(peer["ip"], peer["port"], timeout: 1000) do
      {:ok, socket} -> socket |> handshake(client, info_hash)
      {:error, _} -> exit(:normal)
    end
  end

  defp handshake(socket, client, info_hash) do
    hello = get_handshake_message(client, info_hash)

    socket
    |> Socket.Stream.send!(hello)

    socket
    |> Socket.packet!(:raw)

    request_length =
      socket
      |> recv_byte!(1)
      |> :binary.bin_to_list()
      |> Enum.at(0)

    response = %{
      pstrlen: request_length,
      pstr: recv_byte!(socket, request_length),
      extensions: recv_byte!(socket, 8),
      info_hash: recv_byte!(socket, 20),
      peer_id: recv_byte!(socket, 20)
    }

    {socket, response}
  end

  defp get_handshake_message(client, info_hash) do
    <<19, "BitTorrent protocol"::binary>> <>
      <<0, 0, 0, 0, 0, 0, 0, 0, info_hash::binary>> <>
      <<client[:id]::binary>>
  end

  defp recv_byte!(socket, count) do
    case Socket.Stream.recv(socket, count, timeout: 1000) do
      {:error, _} -> exit(:normal)
      {:ok, nil} -> exit(:normal)
      {:ok, message} -> message
    end
  end
end
