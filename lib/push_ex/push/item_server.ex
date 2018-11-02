defmodule PushEx.Push.ItemServer do
  require Logger

  def start_link(%{
        item: item = %PushEx.Push{channel: channel, event: event},
        at: unix_inserted_at
      }) do
    Task.start_link(fn ->
      ms_since_insertion = PushEx.unix_now() - unix_inserted_at

      PushExWeb.PushChannel.broadcast({:msg, channel}, item)
      |> case do
        {:ok, :broadcast} ->
          Logger.debug("Push.ItemServer broadcast channel=#{channel} event=#{event} ms_in_stage=#{ms_since_insertion}")

        {:ok, :no_listeners} ->
          Logger.debug("Push.ItemServer no_listeners channel=#{channel} event=#{event} ms_in_stage=#{ms_since_insertion}")
      end
    end)
  end
end
