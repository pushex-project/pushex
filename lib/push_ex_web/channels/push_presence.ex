defmodule PushExWeb.PushPresence do
  @moduledoc false

  # Phoenix.Presence propagates presence_diff to channels. However, this is not necessary for pushex
  # use case and sending the message comes at significant cost.
  def handle_diff(_diff, state) do
    {:ok, state}
  end

  use Phoenix.Presence,
    otp_app: :push_ex,
    pubsub_server: PushEx.PubSub

  def track(%Phoenix.Socket{topic: topic} = socket) do
    id = PushEx.Config.socket_impl().presence_identifier(socket)

    track(socket.channel_pid, topic, id, %{
      online_at: PushEx.unix_ms_now()
    })
  end

  def listeners?(topic) do
    topic
    |> list()
    |> Enum.any?()
  end
end
