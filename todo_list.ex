defmodule TodoList do
  use GenServer

  # Callback functions executed on server interface

  def init(_), do: {:ok, []}

  def handle_call({:get, date_tuple}, _, state) do
    {:reply, Enum.filter(state, &(&1.date == date_tuple)), state}
  end

  def handle_call(:list, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:put, todo}, state) do
    {:noreply, [todo | state]}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  # Generic code called by the client

  def start do
    GenServer.start(TodoList, nil)
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
