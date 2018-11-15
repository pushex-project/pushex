defmodule SocketServer.StatsLogger do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(collector: collector_mod, tick: tick_ms, writer: writer_mod) do
    schedule_tick(tick_ms)
    {:ok, %{collector_mod: collector_mod, tick_ms: tick_ms, writer_mod: writer_mod}}
  end

  def handle_info(
        :write,
        state = %{collector_mod: collector_mod, tick_ms: tick_ms, writer_mod: writer_mod}
      ) do
    schedule_tick(tick_ms)

    collector_mod.collect()
    |> writer_mod.write()

    {:noreply, state}
  end

  defp schedule_tick(tick_ms), do: Process.send_after(self(), :write, tick_ms)
end
