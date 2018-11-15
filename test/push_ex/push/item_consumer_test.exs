defmodule PushEx.Push.ItemConsumerTest do
  use ExUnit.Case, async: true

  alias PushEx.Test.MockItemServer
  alias PushEx.Push.{ItemProducer, ItemConsumer}

  @push %PushEx.Push{
    channel: "c",
    event: "e",
    data: "d",
    unix_ms: 0
  }

  describe "GenStage integration" do
    test "all parts work together to process items" do
      agent_pid = MockItemServer.setup()

      {:ok, producer_pid} = ItemProducer.start_link(:nameless)
      {:ok, _consumer_pid} = ConsumerSupervisor.start_link(ItemConsumer, [subscribe_to: producer_pid, worker: MockItemServer], name: __MODULE__)
      push = Map.put(@push, :data, agent_pid)
      at = PushEx.unix_ms_now()
      ItemProducer.push(push, producer_pid)
      ItemProducer.push(push, producer_pid)
      ItemProducer.push(push, producer_pid)

      Process.sleep(30)

      calls = Agent.get(agent_pid, & &1)
      assert [[%{item: ^push, at: test_at}], [%{item: ^push, at: _}], [%{item: ^push, at: _}]] = calls
      assert_in_delta(test_at, at, 5)
    end
  end
end
