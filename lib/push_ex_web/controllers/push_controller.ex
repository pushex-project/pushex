defmodule PushExWeb.PushController do
  use PushExWeb, :controller

  def create(conn, %{"channel" => channel, "data" => data, "event" => event}) do
    channel
    |> List.wrap()
    |> Enum.each(fn channel ->
      PushExWeb.PushChannel.broadcast({:msg, channel}, event, data)
    end)

    conn
    |> json(%{result: "ok"})
  end
end
