defmodule PushExWeb.PushSocket do
  @moduledoc false

  use Phoenix.Socket
  defoverridable init: 1

  # Override Phoenix.Socket init in order to track the socket (with transport_pid) in pushex tracker
  def init(state) do
    super(state)
    |> case do
      res = {:ok, {_, %Phoenix.Socket{} = socket}} ->
        PushEx.Instrumentation.Tracker.track_socket(socket)
        res

      res ->
        res
    end
  end

  channel "*", PushExWeb.PushChannel

  def connect(params, socket) do
    PushEx.Config.socket_impl().socket_connect(params, socket)
  end

  def id(socket) do
    PushEx.Config.socket_impl().socket_id(socket)
  end
end
