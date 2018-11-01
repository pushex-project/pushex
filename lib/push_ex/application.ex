defmodule PushEx.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    PushEx.Config.check!()

    children = [
      pre_endpoint_children(),
      PushExWeb.Endpoint,
      post_endpoint_children(),
    ] |> List.flatten()

    opts = [strategy: :one_for_one, name: PushEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def pre_endpoint_children(), do: [
    PushEx.Push.ItemProducer,
    PushEx.Push.ItemConsumer,
  ]

  def post_endpoint_children(), do: [
    PushExWeb.PushPresence
  ]

  def config_change(changed, _new, removed) do
    PushExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
