defmodule PushEx.Push.DrainerTest do
  use ExUnit.Case, async: true

  alias PushEx.Push.Drainer

  defmodule MockProducer do
    use GenServer

    def start_link(count) do
      GenServer.start_link(__MODULE__, count)
    end

    def init(count) do
      {:ok, %GenStage{buffer: {nil, count, nil}}}
    end

    def set_count(pid, count) do
      GenServer.call(pid, {:set_count, count})
    end

    def kill(pid) do
      try do
        GenServer.call(pid, :kill)
      catch
        _, _ -> nil
      end
    end

    def handle_call({:set_count, count}, _, _) do
      {:reply, :ok, %GenStage{buffer: {nil, count, nil}}}
    end

    def handle_call(:kill, _, state) do
      {:stop, :normal, state}
    end
  end

  test "the process terminates if there are no jobs in the ItemProducer" do
    {:ok, producer_pid} = PushEx.Push.ItemProducer.start_link(:nameless)

    {:ok, drain_pid} =
      Supervisor.start_link(
        [
          {Drainer, producer_ref: producer_pid, shutdown: 1000}
        ],
        strategy: :one_for_one
      )

    Process.exit(drain_pid, :normal) && Process.sleep(20)
    refute Process.alive?(drain_pid)
  end

  test "the ItemProducer can be already dead and it will exit successfully" do
    {:ok, producer_pid} = PushEx.Push.ItemProducer.start_link(:nameless)

    {:ok, drain_pid} =
      Supervisor.start_link(
        [
          {Drainer, producer_ref: producer_pid, shutdown: 1000}
        ],
        strategy: :one_for_one
      )

    assert :ok = GenStage.stop(producer_pid)
    refute Process.alive?(producer_pid)

    Process.exit(drain_pid, :normal) && Process.sleep(25)
    refute Process.alive?(drain_pid)
  end

  test "the drainer will hang for shutdown ms if there is an item in the buffer" do
    {:ok, producer_pid} = PushEx.Push.ItemProducer.start_link(:nameless)

    {:ok, drain_pid} =
      Supervisor.start_link(
        [
          {Drainer, producer_ref: producer_pid, shutdown: 3000}
        ],
        strategy: :one_for_one
      )

    PushEx.Push.ItemProducer.push(%PushEx.Push{channel: nil, data: nil, event: nil, unix_ms: nil}, producer_pid)
    Process.exit(drain_pid, :normal)

    Process.sleep(1000)
    assert Process.alive?(drain_pid)

    Process.sleep(1000)
    assert Process.alive?(drain_pid)

    Process.sleep(600)
    assert Process.alive?(drain_pid)

    Process.sleep(600)
    refute Process.alive?(drain_pid)
  end

  test "the drainer will complete before the shutdown ms if the item in buffer is removed" do
    {:ok, producer_pid} = MockProducer.start_link(1)

    {:ok, drain_pid} =
      Supervisor.start_link(
        [
          {Drainer, producer_ref: producer_pid, shutdown: 3000}
        ],
        strategy: :one_for_one
      )

    Process.exit(drain_pid, :normal)

    Process.sleep(1000)
    assert Process.alive?(drain_pid)

    MockProducer.set_count(producer_pid, 0)

    # Give it slightly more than 1000 as it re-runs that often
    Process.sleep(1100)
    refute Process.alive?(drain_pid)
  end

  test "the drainer will complete before the shutdown ms if the producer pid dies" do
    {:ok, producer_pid} = MockProducer.start_link(1)

    {:ok, drain_pid} =
      Supervisor.start_link(
        [
          {Drainer, producer_ref: producer_pid, shutdown: 3000}
        ],
        strategy: :one_for_one
      )

    Process.exit(drain_pid, :normal)
    Process.sleep(1000)
    assert Process.alive?(drain_pid)

    MockProducer.kill(producer_pid)
    refute Process.alive?(producer_pid)

    # Give it slightly more than 1000 as it re-runs that often
    Process.sleep(1100)
    refute Process.alive?(drain_pid)
  end
end
