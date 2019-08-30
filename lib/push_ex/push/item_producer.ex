defmodule PushEx.Push.ItemProducer do
  @moduledoc false

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

  def in_buffer_count(pid \\ __MODULE__) do
    %GenStage{buffer: {_, size, _}} = :sys.get_state(pid)
    size
  end

  def push(item = %PushEx.Push{}, pid \\ __MODULE__) do
    GenStage.cast(pid, {:notify, item, PushEx.unix_ms_now()})
  end

  def handle_cast({:notify, item, at}, state) do
    {:noreply, [%{item: item, at: at}], state}
  end

  def handle_demand(demand, keys) when demand > 0 do
    {:noreply, [], keys}
  end
end
