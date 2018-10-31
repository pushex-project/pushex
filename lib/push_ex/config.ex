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

  def check!() do
    check_push_socket_connect_fn!()
    check_push_socket_join_fn!()
    check_push_socket_id_fn!()
  end

  defp check_push_socket_connect_fn!() do
    with {:func, func} when not is_nil(func) <- {:func, push_socket_connect_fn()},
         {:arity, 2} <- {:arity, :erlang.fun_info(func)[:arity]} do
      true
    else
      {:func, _} ->
        raise "config :push_ex, PushExWeb.PushSocket, connect_fn/2 must be set"

      {:arity, arity} ->
        raise "config :push_ex, PushExWeb.PushSocket, connect_fn must be arity 2, but is #{arity}"
    end
  end

  defp check_push_socket_join_fn!() do
    with {:func, func} when not is_nil(func) <- {:func, push_socket_join_fn()},
         {:arity, 3} <- {:arity, :erlang.fun_info(func)[:arity]} do
      true
    else
      {:func, _} ->
        raise "config :push_ex, PushExWeb.PushSocket, join_fn/3 must be set"

      {:arity, arity} ->
        raise "config :push_ex, PushExWeb.PushSocket, join_fn must be arity 3, but is #{arity}"
    end
  end

  defp check_push_socket_id_fn!() do
    with {:func, func} when not is_nil(func) <- {:func, push_socket_id_fn()},
         {:arity, 1} <- {:arity, :erlang.fun_info(func)[:arity]} do
      true
    else
      {:func, _} ->
        raise "config :push_ex, PushExWeb.PushSocket, id_fn/1 must be set"

      {:arity, arity} ->
        raise "config :push_ex, PushExWeb.PushSocket, id_fn must be arity 1, but is #{arity}"
    end
  end
end
