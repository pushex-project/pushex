defmodule PushExWeb.SocketDrainerTest do
  use ExUnit.Case, async: true

  alias PushExWeb.SocketDrainer
  alias PushEx.Instrumentation.Tracker

  setup :with_tracker

  test "no connected sockets completes right away", %{pid: pid} do
    PushExWeb.Config.close_connections!(false)

    {:ok, drain_pid} =
      Supervisor.start_link(
        [
          {SocketDrainer, tracker_ref: pid, shutdown: 1000}
        ],
        strategy: :one_for_one
      )

    assert PushExWeb.Config.close_connections?() == false

    Process.exit(drain_pid, :normal) && Process.sleep(50)
    refute Process.alive?(drain_pid)

    assert PushExWeb.Config.close_connections?() == true
  end

  test "1 connected socket doesn't complete", %{pid: pid} do
    {:ok, drain_pid} =
      Supervisor.start_link(
        [
          {SocketDrainer, tracker_ref: pid, shutdown: 1000}
        ],
        strategy: :one_for_one
      )

    transport_pid = spawn(fn -> Process.sleep(10000) end)
    socket = %Phoenix.Socket{transport: :ws, transport_pid: transport_pid}
    PushEx.Test.MockSocket.setup_config()

    assert Tracker.track_socket(socket, pid: pid) == :ok
    Process.sleep(20)
    assert PushEx.Instrumentation.Tracker.connected_socket_count(pid: pid) == 1

    Process.exit(drain_pid, :normal) && Process.sleep(20)
    assert Process.alive?(drain_pid)

    Process.sleep(500)
    assert Process.alive?(drain_pid)

    Process.sleep(500)
    refute Process.alive?(drain_pid)
  end

  test "1 connected socket which ends does", %{pid: pid} do
    {:ok, drain_pid} =
      Supervisor.start_link(
        [
          {SocketDrainer, tracker_ref: pid, shutdown: 1000}
        ],
        strategy: :one_for_one
      )

    transport_pid = spawn(fn -> Process.sleep(10000) end)
    socket = %Phoenix.Socket{transport: :ws, transport_pid: transport_pid}
    PushEx.Test.MockSocket.setup_config()

    assert Tracker.track_socket(socket, pid: pid) == :ok
    Process.sleep(20)
    assert PushEx.Instrumentation.Tracker.connected_socket_count(pid: pid) == 1

    Process.exit(drain_pid, :normal) && Process.sleep(20)
    assert Process.alive?(drain_pid)
    Process.exit(transport_pid, :shutdown)

    Process.sleep(500)
    refute Process.alive?(drain_pid)
  end

  defp with_tracker(_) do
    # Intentionally not linked, as this process will be killed in tests
    {:ok, pid} = GenServer.start(Tracker, [])

    on_exit(fn ->
      Process.exit(pid, :kill)
      PushExWeb.Config.close_connections!(false)
    end)

    {:ok, %{pid: pid}}
  end
end
