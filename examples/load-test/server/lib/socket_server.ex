defmodule SocketServer do
  @behaviour PushEx.Behaviour.Socket
  @behaviour PushEx.Behaviour.Controller

  def socket_connect(_params, socket) do
    socket = Phoenix.Socket.assign(socket, :secret_id, :rand.uniform(999_999))

    {:ok, socket}
  end

  def socket_id(%{assigns: %{secret_id: id}}) do
    "id:#{id}"
  end

  def presence_identifier(socket) do
    socket_id(socket)
  end

  def channel_join(_channel, _params, socket) do
    {:ok, socket}
  end

  def auth(_conn, _params) do
    :ok
  end
end
