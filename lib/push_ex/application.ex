defmodule PushEx.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    PushEx.Config.check!()

    children = [
      PushEx.Push.ItemProducer,
      PushEx.Push.ItemConsumer,
      PushExWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: PushEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    PushExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
