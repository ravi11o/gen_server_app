defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts("Starting todo cache...")
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(todo_list_name) do
    GenServer.call(:todo_cache, {:server_process, todo_list_name})
  end

  def init(_) do
    Todo.Database.start("./persist/")
    {:ok, :ets.new(:cache_registry, [:set, :protected, :named_table])}
  end

  def handle_call({:server_process, todo_list_name}, _, servers) do
    case :ets.lookup(:cache_registry, todo_list_name) do
      [{_, pid} | _] ->
        {:reply, pid, servers}

      [] ->
        {:ok, new_pid} = Todo.List.start(todo_list_name)

        {:reply, new_pid, :ets.insert(:cache_registry, {todo_list_name, new_pid})}
    end
  end
end
