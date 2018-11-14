defmodule PushEx.Push.ItemServer do
  @moduledoc false

  require Logger

  def start_link(
        %{
          item: item = %PushEx.Push{channel: channel, event: event},
          at: unix_inserted_at
        },
        opts \\ []
      ) do
    Task.start_link(fn ->
      channel_api_mod = Keyword.get(opts, :channel_api_mod, PushExWeb.PushChannel)
      ms_since_insertion = PushEx.unix_ms_now() - unix_inserted_at

      channel_api_mod.broadcast({:msg, channel}, item)
      |> case do
        {:ok, :broadcast} ->
          Logger.debug("Push.ItemServer broadcast channel=#{channel} event=#{event} ms_in_stage=#{ms_since_insertion}")

        {:ok, :no_listeners} ->
          Logger.debug("Push.ItemServer no_listeners channel=#{channel} event=#{event} ms_in_stage=#{ms_since_insertion}")
      end
    end)
  end
end
