defmodule PushEx.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    check_config!()
    set_pool_size()

    children = [
      PushEx.Push.ItemProducer,
      PushEx.Push.ItemConsumer,
      PushEx.Instrumentation.Tracker,
      PushEx.Instrumentation.Supervisor
    ]

    opts = [strategy: :one_for_one, name: PushEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  if Mix.env() == :test do
    defp check_config!(), do: nil
  else
    defp check_config!(), do: PushEx.Config.check!()
  end

  def config_change(changed, _new, removed) do
    PushExWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp set_pool_size() do
    presence_pool_size =
      Application.get_env(:push_ex, PushExWeb.Endpoint)
      |> Keyword.get(:pubsub, [])
      |> Keyword.get(:pool_size, 1)

    Application.put_env(:push_ex, :internal_pool_size, presence_pool_size)
  end
end
