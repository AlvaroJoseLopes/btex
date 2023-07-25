defmodule TaskPool do
  use GenServer

  # Client API
  def start_link(pieces) when is_list(pieces) do
    GenServer.start_link(__MODULE__, pieces, name: __MODULE__)
  end

  def request_piece(server) do
    GenServer.call(server, :request_piece)
  end

  def add_piece(server, piece) do
    GenServer.cast(server, {:add_piece, piece})
  end

  def stop(server) do
    GenServer.stop(server, :normal)
  end

  # Server callbacks
  def init(pieces) do
    {:ok, pieces}
  end

  def handle_call(:request_piece, _from, [piece | rest]) do
    {:reply, {:ok, piece}, rest}
  end

  def handle_call(:request_piece, _from, []) do
    {:reply, {:error, :empty}, []}
  end

  def handle_cast({:add_price, piece}, _from, pieces) do
    {:noreply, [piece | pieces]}
  end
end
