defmodule PushEx.Supervisor do
  use Supervisor

  @shutdown_timeout 10_000

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_) do
    children =
      [
        PushExWeb.Endpoint,
        {PushExWeb.PushTracker, [pool_size: PushEx.Application.pool_size()]},
        {PushEx.Push.Drainer, producer_ref: PushEx.Push.ItemProducer, shutdown: @shutdown_timeout}
      ] ++ ranch_connection_drainers()

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.init(children, opts)
  end

  defp ranch_connection_drainers() do
    ranch_connection_drainer_http() ++ ranch_connection_drainer_https()
  end

  defp ranch_connection_drainer_http() do
    if Application.get_env(:push_ex, PushExWeb.Endpoint) |> Keyword.get(:http) do
      [
        %{
          id: RanchConnectionDrainer.HTTP,
          start: {RanchConnectionDrainer, :start_link, [PushExWeb.Endpoint.HTTP]},
          shutdown: @shutdown_timeout
        }
      ]
    else
      []
    end
  end

  defp ranch_connection_drainer_https() do
    if Application.get_env(:push_ex, PushExWeb.Endpoint) |> Keyword.get(:https) do
      [
        %{
          id: RanchConnectionDrainer.HTTPS,
          start: {RanchConnectionDrainer, :start_link, [PushExWeb.Endpoint.HTTPS]},
          shutdown: @shutdown_timeout
        }
      ]
    else
      []
    end
  end
end
