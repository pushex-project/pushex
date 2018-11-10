defmodule PushExWeb.PushSocket do
  @moduledoc false

  def init(state) do
    case Phoenix.Socket.__init__(state) do
      res = {:ok, {_, %Phoenix.Socket{} = socket}} ->
        PushEx.Instrumentation.Tracker.track_socket(socket)
        res

      res ->
        res
    end
  end

  use Phoenix.Socket

  channel "*", PushExWeb.PushChannel

  def connect(params, socket) do
    PushEx.Config.socket_impl().socket_connect(params, socket)
  end

  def id(socket) do
    PushEx.Config.socket_impl().socket_id(socket)
  end
end
