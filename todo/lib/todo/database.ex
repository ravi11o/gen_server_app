defmodule Todo.Database do
  use GenServer

  def start_link(db_folder) do
    IO.puts("Starting todo database...")
    GenServer.start_link(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    worker = get_worker(key)
    GenServer.cast(worker, {:store, key, data})
  end

  def get(key) do
    worker = get_worker(key)
    GenServer.call(worker, {:get, key})
  end

  def init(db_folder) do
    File.mkdir_p(db_folder)
    :ets.new(:db_workers, [:set, :protected, :named_table])

    0..2
    |> Enum.each(fn i ->
      {_, pid} = Todo.DatabaseWorker.start_link(db_folder)
      :ets.insert(:db_workers, {i, pid})
    end)

    {:ok, nil}
  end

  def get_worker(key) do
    index = :erlang.phash2(key, 3)
    [{_, pid}] = :ets.lookup(:db_workers, index)
    pid
  end
end
