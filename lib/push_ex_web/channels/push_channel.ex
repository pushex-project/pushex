defmodule PushExWeb.PushChannel do
  use Phoenix.Channel

  intercept(["msg"])

  def broadcast({:msg, channel}, event, data = %{}) when is_bitstring(event) do
    PushExWeb.Endpoint.broadcast!(channel, "msg", %{event: event, data: data})
    :ok
  end

  ## Socket API

  def join(channel, params, socket) do
    PushEx.Config.push_socket_join_fn().(channel, params, socket)
  end

  def handle_out("msg", params = %{}, socket) do
    push(socket, "msg", params)
    {:noreply, socket}
  end
end
