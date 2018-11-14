defmodule PushExWeb.PushPresence do
  @moduledoc false

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
