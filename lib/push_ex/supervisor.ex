defmodule PushEx.Supervisor do
  use Supervisor

  @shutdown_timeout 10_000

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_) do
    children =
      [
        PushExWeb.Config,
        {Phoenix.PubSub, pubsub_config()},
        if(!custom_endpoint?(), do: endpoint_module()),
        {PushExWeb.PushTracker, [pool_size: PushEx.Application.pool_size()]},
        {PushEx.Push.Drainer, producer_ref: PushEx.Push.ItemProducer, shutdown: @shutdown_timeout}
      ] ++ ranch_connection_drainers() ++ socket_drainer()

    children = Enum.reject(children, & is_nil/1)

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.init(children, opts)
  end

  def pubsub_config() do
    config = Application.get_env(:push_ex, PushEx.PubSub, [])
    Keyword.merge([name: PushEx.PubSub, adapter: Phoenix.PubSub.PG2], config)
  end

  defp endpoint_module do
    PushEx.Config.endpoint_config().module
  end

  defp custom_endpoint? do
    endpoint_module() != PushExWeb.Endpoint
  end

  defp ranch_connection_drainers() do
    ranch_connection_drainer_endpoints()
    |> Enum.map(fn phx_endpoint_mod ->
      %{
        id: Module.concat(RanchConnectionDrainer, phx_endpoint_mod),
        start: {RanchConnectionDrainer, :start_link, [phx_endpoint_mod]},
        shutdown: @shutdown_timeout
      }
    end)
  end

  defp socket_drainer() do
    if PushEx.Config.disconnect_sockets_on_shutdown() do
      [
        {PushExWeb.SocketDrainer, shutdown: @shutdown_timeout, ranch_refs: ranch_connection_drainer_endpoints()}
      ]
    else
      []
    end
  end

  defp ranch_connection_drainer_endpoints() do
    ranch_connection_drainer_http() ++ ranch_connection_drainer_https()
  end

  defp ranch_connection_drainer_http() do
    %{otp_app: otp_app, module: endpoint_mod} = PushEx.Config.endpoint_config()

    if Application.get_env(otp_app, endpoint_mod) |> Keyword.get(:http) do
      [PushExWeb.Endpoint.HTTP]
    else
      []
    end
  end

  defp ranch_connection_drainer_https() do
    %{otp_app: otp_app, module: endpoint_mod} = PushEx.Config.endpoint_config()

    if Application.get_env(otp_app, endpoint_mod) |> Keyword.get(:https) do
      [PushExWeb.Endpoint.HTTPS]
    else
      []
    end
  end
end
