defmodule PushEx.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_) do
    children = [
      PushExWeb.Endpoint,
      {PushExWeb.PushTracker, [pool_size: PushEx.Application.pool_size()]},
      {PushEx.Push.Drainer, producer_ref: PushEx.Push.ItemProducer, shutdown: 15_000},
      {RanchConnectionDrainer, ranch_ref: endpoint_mod(), shutdown: 15_000}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.init(children, opts)
  end

  defp endpoint_mod() do
    if Application.get_env(:push_ex, PushExWeb.Endpoint) |> Keyword.get(:https) do
      PushExWeb.Endpoint.HTTPS
    else
      PushExWeb.Endpoint.HTTP
    end
  end
end
