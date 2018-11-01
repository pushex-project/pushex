defmodule PushEx.Push.ItemConsumer do
  use ConsumerSupervisor

  alias PushEx.Push.{ItemProducer, ItemServer}

  def start_link(_) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(ItemServer, [], restart: :transient)
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {ItemProducer, max_demand: PushEx.Config.producer_max_concurrency(), min_demand: 1}
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
