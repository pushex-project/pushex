defmodule PushExWeb.PushController do
  use PushExWeb, :controller

  def create(conn, %{"channel" => channel, "data" => data, "event" => event}) do
    wrapped_channel = List.wrap(channel)

    wrapped_channel
    |> Enum.each(fn channel ->
      PushExWeb.PushChannel.broadcast({:msg, channel}, event, data)
    end)

    conn
    |> json(%{channel: wrapped_channel, data: data, event: event})
  end
end
