defmodule PushEx.Config do
  def socket_impl() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:socket_impl)
  end

  def controller_impl() do
    Application.get_env(:push_ex, PushExWeb.PushController, [])
    |> Keyword.get(:controller_impl)
  end

  def producer_max_buffer() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:max_producer_buffer, 50_000)
  end

  def producer_max_concurrency() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:max_producer_concurrency, 10)
  end

  def endpoint() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:endpoint, PushExWeb.Endpoint)
  end

  def check!() do
    check_socket_impl!()
    check_controller_impl!()
  end

  defp check_socket_impl!() do
    socket_impl()
    |> case do
      nil ->
        raise "config :push_ex, PushExWeb.PushSocket, socket_impl: ModName must be set"

      _ ->
        true
    end
  end

  defp check_controller_impl!() do
    controller_impl()
    |> case do
      nil ->
        raise "config :push_ex, PushExWeb.PushController, controller_impl: ModName must be set"

      _ ->
        true
    end
  end
end
