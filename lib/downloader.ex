defmodule Downloader do
  def start(workpool) do
    Task.async(fn -> loop(workpool, %{}) end)
  end

  defp loop(workpool, downloads) do
    case TaskPool.request_piece(workpool) do
      {:ok, piece} ->
        IO.puts("Worker #{inspect(self())} downloaded piece #{piece}")
        loop(workpool, Map.put(downloads, piece, [:downloaded, "bytes..."]))

      {:error, :empty} ->
        IO.puts("Empty pool. Worker #{inspect(self())} is done.")
        {:ok, downloads}
    end
  end
end
