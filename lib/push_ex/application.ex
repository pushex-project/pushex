defmodule PushEx.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    check_config!()

    children =
      [
        pre_endpoint_children(),
        PushExWeb.Endpoint,
        post_endpoint_children()
      ]
      |> List.flatten()

    opts = [strategy: :one_for_one, name: PushEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  if Mix.env() == :test do
    defp check_config!(), do: nil
  else
    defp check_config!(), do: PushEx.Config.check!()
  end

  def pre_endpoint_children(),
    do: [
      PushEx.Push.ItemProducer,
      PushEx.Push.ItemConsumer,
      PushEx.Instrumentation.Tracker
    ]

  def post_endpoint_children(),
    do: [
      PushExWeb.PushPresence
    ]

  def config_change(changed, _new, removed) do
    PushExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
