defmodule SocketServer.StatsLogger do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(tick: tick_ms) do
    schedule_tick(tick_ms)
    {:ok, %{tick_ms: tick_ms}}
  end

  def handle_info(:write, state = %{tick_ms: tick_ms}) do
    schedule_tick(tick_ms)
    IO.puts(log_line())
    {:noreply, state}
  end

  defp schedule_tick(tick_ms), do: Process.send_after(self(), :write, tick_ms)

  defp log_line() do
    [
      PushEx.Instrumentation.Tracker.connected_socket_count(),
      PushEx.Instrumentation.Tracker.connected_channel_count(),
    ] |> Enum.join(", ")
  end
end
