defmodule Peer do
  @moduledoc """
  Peer module.
  """

  @version  "0001"
  @port      6889

  defstruct [
    :id, :port, version: @version, uploaded: 0, downloaded: 0, compact: 1
  ]

  def fetch(map, key), do: Map.fetch(map, key)

  @doc """
  Create a new Peer struct.
  """
  def new(port \\ @port) do
    %Peer{id: generate_id(), port: port}
  end

  defp generate_id() do
    rand_number =
      :rand.uniform(1000000000000) - 1
      |> Integer.to_string()
      |> String.pad_leading(12, "0")

    <<"-EX">> <> <<@version>> <> <<"-">> <> <<rand_number::binary>>
  end
end
