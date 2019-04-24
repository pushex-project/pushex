# Heavily influenced by RanchConnectionDrainer and :ranch
defmodule PushEx.Push.Drainer do
  @moduledoc false

  use GenServer
  require Logger

  def child_spec(options) when is_list(options) do
    producer_ref = Keyword.fetch!(options, :producer_ref)
    shutdown = Keyword.fetch!(options, :shutdown)

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [producer_ref]},
      shutdown: shutdown
    }
  end

  def start_link(producer_ref) do
    GenServer.start_link(__MODULE__, producer_ref)
  end

  def init(producer_ref) do
    Process.flag(:trap_exit, true)
    {:ok, producer_ref}
  end

  def terminate(_reason, producer_ref) do
    Logger.info("Waiting for producer to drain for PushEx.Producer #{inspect(producer_ref)}...")
    :ok = wait_for_drain_loop(producer_ref)
    Logger.info("Producer successfully drained for PushEx.Producer #{inspect(producer_ref)}")
  end

  defp wait_for_drain_loop(producer_ref) do
    count =
      try do
        PushEx.Push.ItemProducer.in_buffer_count(producer_ref)
      catch
        _, _ ->
          0
      end

    if count == 0 do
      :ok
    else
      Process.sleep(1000)
      wait_for_drain_loop(producer_ref)
    end
  end
end
