defmodule PushEx.Push.ItemProducerTest do
  use ExUnit.Case, async: true

  alias PushEx.Test.MockItemServer
  alias PushEx.Push.{ItemConsumer, ItemProducer}

  @push %PushEx.Push{
    channel: "c",
    event: "e",
    data: "d",
    unix_ms: 0
  }

  describe "in_buffer_count/0" do
    test "the producer buffer size is returned" do
      agent_pid = MockItemServer.setup()
      {:ok, producer_pid} = ItemProducer.start_link(:nameless)
      push = Map.put(@push, :data, agent_pid)

      # We start with no items
      assert ItemProducer.in_buffer_count(producer_pid) == 0

      # Add 2 items and see the count increase each time
      ItemProducer.push(push, producer_pid)
      assert ItemProducer.in_buffer_count(producer_pid) == 1
      ItemProducer.push(push, producer_pid)
      assert ItemProducer.in_buffer_count(producer_pid) == 2

      # Start the consumer and allow it to process
      {:ok, _consumer_pid} = ConsumerSupervisor.start_link(ItemConsumer, [subscribe_to: producer_pid, worker: MockItemServer], name: __MODULE__)
      Process.sleep(30)

      # The count is back to 0
      assert ItemProducer.in_buffer_count(producer_pid) == 0
    end
  end
end
