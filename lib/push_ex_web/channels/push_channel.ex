defmodule PushExWeb.PushChannel do
  use Phoenix.Channel

  alias PushExWeb.PushPresence
  alias PushEx.Instrumentation

  intercept(["msg"])

  def broadcast({:msg, channel}, item = %PushEx.Push{event: event}, opts \\ []) when is_bitstring(event) do
    if PushPresence.listeners?(channel) do
      endpoint_mod = Keyword.get(opts, :endpoint, PushEx.Config.endpoint())
      endpoint_mod.broadcast!(channel, "msg", item)
      {:ok, :broadcast}
    else
      {:ok, :no_listeners}
    end
  end

  ## Socket API

  def join(channel, params, socket) do
    PushEx.Config.push_socket_join_fn().(channel, params, socket)
    |> case do
      response = {:ok, _socket} ->
        send(self(), :after_join)
        response

      response ->
        response
    end
  end

  def handle_out("msg", item = %PushEx.Push{data: data, event: event}, socket) do
    push(socket, "msg", %{data: data, event: event})
    Instrumentation.Push.delivered(item)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    :ok = Instrumentation.Tracker.track_channel(socket)
    {:ok, _} = PushPresence.track(socket)
    {:noreply, socket}
  end
end
