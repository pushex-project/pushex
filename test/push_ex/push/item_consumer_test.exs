defmodule PushEx.Push.ItemConsumerTest do
  use ExUnit.Case, async: true

  alias PushEx.Push.{ItemProducer, ItemConsumer}

  defmodule MockItemServer do
    def setup() do
      {:ok, agent} = Agent.start_link(fn -> [] end)
      agent
    end

    def start_link(arg = %{
          item: %PushEx.Push{data: agent_pid},
          at: _
        }) do
      Task.start_link(fn ->
        # Maintain async by passing in the agent_pid through the item
        Agent.update(agent_pid, fn calls -> [[arg] | calls] end)
      end)
    end
  end

  @push %PushEx.Push{
    channel: "c",
    event: "e",
    data: "d"
  }

  describe "GenStage integration" do
    test "all parts work together to process items" do
      agent_pid = MockItemServer.setup()

      {:ok, producer_pid} = ItemProducer.start_link(:nameless)
      {:ok, _consumer_pid} = ConsumerSupervisor.start_link(ItemConsumer, [subscribe_to: producer_pid, worker: MockItemServer], name: __MODULE__)
      push = Map.put(@push, :data, agent_pid)
      at = PushEx.unix_now()
      ItemProducer.push(push, producer_pid)
      ItemProducer.push(push, producer_pid)
      ItemProducer.push(push, producer_pid)

      Process.sleep(30)

      calls = Agent.get(agent_pid, & &1)
      assert calls == [[%{item: push, at: at}], [%{item: push, at: at}], [%{item: push, at: at}]]
    end
  end
end
