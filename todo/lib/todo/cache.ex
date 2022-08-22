defmodule Todo.Cache do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  def init(_), do: {:ok, :ets.new(:cache_registry, [:set, :protected, :named_table])}

  def handle_call({:server_process, todo_list_name}, _, servers) do
    case :ets.lookup(:cache_registry, todo_list_name) do
      [{_, pid} | _] ->
        {:reply, pid, servers}

      [] ->
        {:ok, new_pid} = Todo.List.start()

        {:reply, new_pid, :ets.insert(:cache_registry, {todo_list_name, new_pid})}
    end
  end
end
