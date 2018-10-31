defmodule PushExWeb.PushSocket do
  use Phoenix.Socket

  channel "*", PushExWeb.PushChannel

  def connect(params, socket) do
    PushEx.Config.push_socket_connect_fn().(params, socket)
  end

  def id(socket) do
    PushEx.Config.push_socket_id_fn().(socket)
  end
end
