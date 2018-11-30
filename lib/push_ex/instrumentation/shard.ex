defmodule PushEx.Instrumentation.Shard do
  @moduledoc false

  use GenServer

  def name_for_number(n, prefix) do
    :"#{prefix}_#{n}"
  end

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init(_) do
    {:ok, %{}}
  end

  def execute(pid, func) when is_function(func) do
    GenServer.cast(pid, {:exec, func})
  end

  def handle_cast({:exec, func}, state) do
    func.()
    {:noreply, state}
  end
end
