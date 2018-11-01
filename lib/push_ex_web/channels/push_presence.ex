defmodule PushExWeb.PushPresence do
  use Phoenix.Presence,
    otp_app: :push_ex,
    pubsub_server: PushEx.PubSub

  def track(%Phoenix.Socket{topic: topic} = socket) do
    id = PushEx.Config.presence_identifier_fn().(socket)

    track(socket.channel_pid, topic, id, %{
      online_at: PushEx.unix_now()
    })
  end

  def listeners?(topic) do
    topic
    |> list()
    |> Enum.any?()
  end
end
