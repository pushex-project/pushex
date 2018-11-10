defmodule TestFrontendSocket do
  @behaviour PushEx.SocketBehaviour
  @behaviour PushEx.ControllerBehaviour

  def socket_connect(params, socket) do
    IO.inspect({"my socket_connect invoked with", params, socket})

    socket = Phoenix.Socket.assign(socket, :secret_id, :rand.uniform(999_999))

    {:ok, socket}
  end

  def socket_id(%{assigns: %{secret_id: id}}) do
    "id:#{id}"
  end

  def presence_identifier(socket) do
    socket_id(socket)
  end

  def channel_join(channel, params, socket) do
    IO.inspect({"my channel_join invoked with", channel, params, socket})
    {:ok, socket}
  end

  def auth(_conn, _params) do
    :ok
  end
end
