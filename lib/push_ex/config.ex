defmodule PushEx.Config do
  @moduledoc false

  @doc """
  Module to be used for PushEx.Behaviour.Socket implementation
  """
  def socket_impl() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:socket_impl)
  end

  @doc """
  Module to be used for PushEx.Behaviour.Controller implementation
  """
  def controller_impl() do
    Application.get_env(:push_ex, PushExWeb.PushController, [])
    |> Keyword.get(:controller_impl)
  end

  @doc """
  The maximum size of the GenStage item buffer. Increasing this will consume more memory,
  but will be able to have more items waiting in the case of a serious backup.
  """
  def producer_max_buffer() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:producer_max_buffer, 50_000)
  end

  @doc """
  Concurrency threshold to take items off of the GenStage item buffer.
  """
  def producer_max_concurrency() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:producer_max_concurrency, 10)
  end

  @doc """
  The Phoenix.Endpoint implementation to be used.
  """
  def endpoint() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:endpoint, PushExWeb.Endpoint)
  end

  @doc """
  List of instrumentation modules that implement PushEx.Behaviour.PushInstrumentation, to be invoked at
  different hook points.
  """
  def push_listeners() do
    Application.get_env(:push_ex, PushEx.Instrumentation, [])
    |> Keyword.get(:push_listeners, [])
  end

  @doc """
  The list of topics which should be treated as always online and not tracked. This is useful for the situation
  where there is a public topic that most likely always has a listener. It is very expensive to track these topics.
  These topics will be tracked in `Instrumentation.Tracker` but not `Phoenix.Tracker` for performance reasons.
  """
  def untracked_push_tracker_topics() do
    Application.get_env(:push_ex, PushExWeb.PushTracker, [])
    |> Keyword.get(:untracked_topics, [])
  end

  @doc """
  Whether to disable the tracker, defaults to false. This is useful in high join-throughput environments where tracker
  may put CPU pressure on the node. When the tracker is disabled, every message will be broadcasted.
  """
  def tracker_disabled?() do
    Application.get_env(:push_ex, PushExWeb.PushTracker, [])
    |> Keyword.get(:tracker_disabled?, false)
  end

  @doc """
  Whether sockets will be automatically disconnected on shutdown, defaults to false for safety reasons
  """
  def disconnect_sockets_on_shutdown() do
    Application.get_env(:push_ex, PushExWeb.PushSocket, [])
    |> Keyword.get(:disconnect_sockets_on_shutdown, false)
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
