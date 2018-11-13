defmodule PushEx.Push.ItemConsumer do
  @moduledoc false

  use ConsumerSupervisor

  alias PushEx.Push.{ItemProducer, ItemServer}

  def start_link(_) do
    ConsumerSupervisor.start_link(__MODULE__, [subscribe_to: ItemProducer, worker: ItemServer], name: __MODULE__)
  end

  def init(subscribe_to: subscribe_mod, worker: worker_mod) do
    children = [
      worker(worker_mod, [], restart: :transient)
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {subscribe_mod, max_demand: PushEx.Config.producer_max_concurrency(), min_demand: 1}
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
