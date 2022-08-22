defmodule Todo.List do
  use GenServer

  # Callback functions executed on server interface

  def init(todo_list_name) do
    {:ok, {todo_list_name, Todo.Database.get(todo_list_name) || []}}
  end

  def handle_call({:get, date_tuple}, _, {todo_name, state}) do
    {:reply, Enum.filter(state, &(&1.date == date_tuple)), {todo_name, state}}
  end

  def handle_call(:list, _, {todo_name, state}) do
    {:reply, state, {todo_name, state}}
  end

  def handle_cast({:put, todo}, {todo_name, state}) do
    new_state = [todo | state]
    Todo.Database.store(todo_name, todo)
    {:noreply, {todo_name, new_state}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  # Generic code called by the client

  def start(todo_list_name) do
    GenServer.start(__MODULE__, todo_list_name)
  end

  def add(pid, todo) do
    GenServer.cast(pid, {:put, todo})
  end

  def filter(pid, date) do
    GenServer.call(pid, {:get, date})
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end
end
