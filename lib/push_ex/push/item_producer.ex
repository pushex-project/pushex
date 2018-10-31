defmodule PushEx.Push.ItemProducer do
  use GenStage

  def start_link(:nameless) do
    GenStage.start_link(__MODULE__, :ok)
  end

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer, [], [buffer_size: PushEx.Config.producer_max_buffer()]}
  end

  def push(item = %PushEx.Push{}, pid \\ __MODULE__) do
    GenStage.cast(pid, {:notify, item})
  end

  def handle_cast({:notify, item}, state) do
    {:noreply, [%{item: item, at: PushEx.unix_now()}], state}
  end

  def handle_demand(demand, keys) when demand > 0 do
    {:noreply, [], keys}
  end
end
