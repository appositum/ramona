defmodule Ramona.Reminder do
  def new do
    Agent.start(fn -> [] end)
  end

  def get(pid) do
    Agent.get(pid, fn lst -> lst end)
  end

  def add(pid, value) do
    Agent.update(pid, fn lst -> [value | lst] end)
  end

  def reload(pid) do
    Agent.update(pid, fn lst -> Enum.filter(lst, &Process.alive?/1) end)
  end

  def time_in_seconds(lst) do
    Enum.map(lst, &Integer.parse/1)
    |> Enum.map(fn
      {n, "h"} -> n * 60 * 60
      {n, "m"} -> n * 60
      {n, "s"} -> n
    end)
    |> Enum.sum()
  end
end
