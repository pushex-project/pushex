defmodule PushEx.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_) do
    children = [
      PushExWeb.Endpoint,
      {PushExWeb.PushTracker, [pool_size: PushEx.Application.pool_size()]},
      {RanchConnectionDrainer, ranch_ref: PushExWeb.Endpoint.HTTP, shutdown: 15_000}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.init(children, opts)
  end
end
