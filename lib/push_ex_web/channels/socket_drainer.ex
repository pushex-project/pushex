defmodule PushExWeb.SocketDrainer do
  @moduledoc false

  use GenServer
  require Logger

  def child_spec(options) when is_list(options) do
    tracker_ref = Keyword.get(options, :tracker_ref, PushEx.Instrumentation.Tracker)
    shutdown = Keyword.fetch!(options, :shutdown)

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [tracker_ref]},
      shutdown: shutdown
    }
  end

  def start_link(tracker_ref) do
    GenServer.start_link(__MODULE__, [tracker_ref])
  end

  def init([tracker_ref]) do
    Process.flag(:trap_exit, true)
    {:ok, tracker_ref}
  end

  def terminate(_reason, tracker_ref) do
    Logger.info("Waiting for sockets to drain for PushExWeb.PushSocket #{inspect(tracker_ref)}...")
    :ok = wait_for_drain_loop(tracker_ref)
    Logger.info("Sockets successfully drained for PushExWeb.PushSocket #{inspect(tracker_ref)}")
  end

  defp wait_for_drain_loop(tracker_ref) do
    if connected_socket_count(tracker_ref) == 0 do
      :ok
    else
      kill_all_socket_connections(tracker_ref)
      Process.sleep(100)
      wait_for_drain_loop(tracker_ref)
    end
  end

  defp connected_socket_count(tracker_ref) do
    try do
      PushEx.Instrumentation.Tracker.connected_socket_count(pid: tracker_ref)
    catch
      _, _ ->
        0
    end
  end

  defp connected_socket_pids(tracker_ref) do
    try do
      PushEx.Instrumentation.Tracker.connected_transport_pids(pid: tracker_ref)
    catch
      _, _ ->
        []
    end
  end

  defp kill_all_socket_connections(tracker_ref) do
    connected_socket_pids(tracker_ref)
    |> Enum.each(fn pid ->
      send(pid, %Phoenix.Socket.Broadcast{event: "disconnect"})
    end)
  end
end
