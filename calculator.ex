defmodule Calculator do
  def start do
    spawn(fn -> loop(0) end)
  end

  # Client Requests

  def value(server_pid) do
    send(server_pid, {:value, self()})

    receive do
      {:response, value} -> value
    end
  end

  def add(server_pid, num), do: send(server_pid, {:add, num})
  def subtract(server_pid, num), do: send(server_pid, {:subtract, num})
  def multiply(server_pid, num), do: send(server_pid, {:multiply, num})
  def divide(server_pid, num), do: send(server_pid, {:divide, num})

  # Server process response

  defp loop(state) do
    new_state =
      receive do
        message -> process_message(state, message)
      end

    loop(new_state)
  end

  defp process_message(state, {:value, caller}) do
    send(caller, {:response, state})
    state
  end

  defp process_message(state, {:add, num}), do: state + num
  defp process_message(state, {:subtract, num}), do: state - num
  defp process_message(state, {:multiply, num}), do: state * num
  defp process_message(state, {:divide, num}), do: state / num
end

