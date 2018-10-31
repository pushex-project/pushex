defmodule PushExWeb.PushChannel do
  use Phoenix.Channel

  intercept(["msg"])

  def broadcast({:msg, channel}, event, data = %{}) when is_bitstring(event) do
    PushExWeb.Endpoint.broadcast!(channel, "msg", %{event: event, data: data})
    :ok
  end

  ## Socket API

  def join(_ch, _params, socket) do
    {:ok, socket}
  end

  def handle_out("msg", params = %{}, socket) do
    push(socket, "msg", params)
    {:noreply, socket}
  end
end
