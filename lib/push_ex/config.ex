defmodule PushEx.Config do
  def push_socket_connect_fn() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:connect_fn)
  end

  def push_socket_join_fn() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:join_fn)
  end

  def push_socket_id_fn() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:id_fn)
  end

  def producer_max_buffer() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:max_producer_buffer, 50_000)
  end

  def producer_max_concurrency() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:max_producer_concurrency, 10)
  end

  def presence_identifier_fn() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:presence_identifier_fn)
  end

  def endpoint() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:endpoint, PushExWeb.Endpoint)
  end

  def controller_auth_fn() do
    Application.get_env(:push_ex, PushExWeb.PushController, [])
    |> Keyword.get(:auth_fn)
  end

  def check!() do
    check_push_socket_connect_fn!()
    check_push_socket_join_fn!()
    check_push_socket_id_fn!()
    check_presence_identifier_fn!()
    check_controller_auth_fn!()
  end

  defp check_push_socket_connect_fn!() do
    check_fn!(:connect_fn, :push_socket_connect_fn, 2)
  end

  defp check_push_socket_join_fn!() do
    check_fn!(:join_fn, :push_socket_join_fn, 3)
  end

  defp check_push_socket_id_fn!() do
    check_fn!(:id_fn, :push_socket_id_fn, 1)
  end

  defp check_presence_identifier_fn!() do
    check_fn!(:presence_identifier_fn, :presence_identifier_fn, 1)
  end

  defp check_controller_auth_fn!() do
    check_fn!(:auth_fn, :controller_auth_fn, 2, config_mod: PushExWeb.PushController)
  end

  def check_fn!(config_name, func_name, expected_arity, opts \\ []) do
    config_mod =
      Keyword.get(opts, :config_mod, PushExWeb.PushSocket)
      |> to_string()
      |> String.replace("Elixir.", "")

    with {:func, func} when not is_nil(func) <- {:func, apply(__MODULE__, func_name, [])},
         {:arity, ^expected_arity} <- {:arity, :erlang.fun_info(func)[:arity]} do
      true
    else
      {:func, _} ->
        raise "config :push_ex, #{config_mod}, #{config_name}/#{expected_arity} must be set"

      {:arity, arity} ->
        raise "config :push_ex, #{config_mod}, #{config_name} must be arity #{expected_arity}, but is #{arity}"
    end
  end
end
