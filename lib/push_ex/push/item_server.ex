defmodule PushEx.Push.ItemServer do
  require Logger

  def start_link(%{
        item: %PushEx.Push{channel: channel, data: data, event: event},
        at: unix_inserted_at
      }) do
    Task.start_link(fn ->
      ms_since_insertion = PushEx.unix_now() - unix_inserted_at

      Logger.debug(
        "Push.ItemServer broadcast channel=#{channel} event=#{event} ms_in_stage=#{
          ms_since_insertion
        }"
      )

      PushExWeb.PushChannel.broadcast({:msg, channel}, event, data)
    end)
  end
end
