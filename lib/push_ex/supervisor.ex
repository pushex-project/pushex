defmodule PushEx.Supervisor do
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_) do
    check_config!()
    set_pool_size()

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.init(children(), opts)
  end

  def children() do
    [
      pre_endpoint_children(),
      PushExWeb.Endpoint,
      post_endpoint_children()
    ]
    |> List.flatten()
  end

  def pre_endpoint_children(),
    do: [
      PushEx.Push.ItemProducer,
      PushEx.Push.ItemConsumer,
      PushEx.Instrumentation.Tracker,
      PushEx.Instrumentation.Supervisor
    ]

  def post_endpoint_children(),
    do: [
      {PushExWeb.PushTracker, [pool_size: pool_size()]}
    ]

  def pool_size do
    Application.get_env(:push_ex, :internal_pool_size, 1)
  end

  if Mix.env() == :test do
    defp check_config!(), do: nil
  else
    defp check_config!(), do: PushEx.Config.check!()
  end

  defp set_pool_size() do
    presence_pool_size =
      Application.get_env(:push_ex, PushExWeb.Endpoint)
      |> Keyword.get(:pubsub, [])
      |> Keyword.get(:pool_size, 1)

    Application.put_env(:push_ex, :internal_pool_size, presence_pool_size)
  end
end
