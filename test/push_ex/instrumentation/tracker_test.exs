defmodule PushEx.Instrumentation.TrackerTest do
  use ExUnit.Case, async: false

  alias PushEx.Instrumentation.Tracker

  describe "track_channel/1" do
    setup :with_tracker

    test "the process is tracked in state, and becomes untracked when it ends", %{pid: pid} do
      channel_pid = spawn(fn -> Process.sleep(10000) end)
      channel_pid2 = spawn(fn -> Process.sleep(10000) end)
      socket = %Phoenix.Socket{topic: "topic", channel_pid: channel_pid}
      socket2 = %Phoenix.Socket{topic: "topic2", channel_pid: channel_pid2}
      PushEx.Test.MockSocket.setup_config()

      assert Tracker.track_channel(socket, pid: pid) == :ok

      assert %{
               channel_pids: %{^channel_pid => %{channel: "topic", identifier: "id", online_at: _}},
               transport_pids: %{}
             } = Tracker.state(pid: pid)

      assert Tracker.connected_channel_count(pid: pid) == 1
      assert Tracker.connected_socket_count(pid: pid) == 0

      assert Tracker.track_channel(socket2, pid: pid) == :ok

      empty_map = %{}

      assert %{
               channel_pids: %{
                 ^channel_pid => %{channel: "topic", identifier: "id", online_at: _},
                 ^channel_pid2 => %{channel: "topic2", identifier: "id", online_at: _}
               },
               transport_pids: ^empty_map
             } = Tracker.state(pid: pid)

      assert Tracker.connected_channel_count(pid: pid) == 2

      Process.exit(channel_pid, :kill) && Process.sleep(10)
      assert Tracker.connected_channel_count(pid: pid) == 1
      Process.exit(channel_pid2, :kill) && Process.sleep(10)
      assert Tracker.connected_channel_count(pid: pid) == 0

      assert Tracker.state(pid: pid) == %{
               channel_pids: %{},
               transport_pids: %{}
             }

      assert Process.alive?(pid)
    end

    test "the linked processes die if the tracker dies", %{pid: pid} do
      channel_pid = spawn(fn -> Process.sleep(10000) end)
      socket = %Phoenix.Socket{topic: "topic", channel_pid: channel_pid}
      channel_pid2 = spawn(fn -> Process.sleep(10000) end)
      socket2 = %Phoenix.Socket{topic: "topic", channel_pid: channel_pid2}
      PushEx.Test.MockSocket.setup_config()

      assert Tracker.track_channel(socket, pid: pid) == :ok
      assert Tracker.track_channel(socket2, pid: pid) == :ok

      Process.exit(pid, :kill)
      Process.sleep(10)

      refute Process.alive?(pid)
      refute Process.alive?(channel_pid)
      refute Process.alive?(channel_pid)
    end
  end

  describe "track_socket/1" do
    setup :with_tracker

    test "the process is tracked in state, and becomes untracked when it ends", %{pid: pid} do
      transport_pid = spawn(fn -> Process.sleep(10000) end)
      transport_pid2 = spawn(fn -> Process.sleep(10000) end)
      socket = %Phoenix.Socket{transport: :ws, transport_pid: transport_pid}
      socket2 = %Phoenix.Socket{transport: :ws, transport_pid: transport_pid2}
      PushEx.Test.MockSocket.setup_config()

      assert Tracker.track_socket(socket, pid: pid) == :ok
      empty_map = %{}

      assert %{
               channel_pids: ^empty_map,
               transport_pids: %{^transport_pid => %{type: :ws, identifier: "id", online_at: _}}
             } = Tracker.state(pid: pid)

      assert Tracker.connected_channel_count(pid: pid) == 0
      assert Tracker.connected_socket_count(pid: pid) == 1

      assert Tracker.track_socket(socket2, pid: pid) == :ok
      empty_map = %{}

      assert %{
               channel_pids: ^empty_map,
               transport_pids: %{
                 ^transport_pid => %{type: :ws, identifier: "id", online_at: _},
                 ^transport_pid2 => %{type: :ws, identifier: "id", online_at: _}
               }
             } = Tracker.state(pid: pid)

      Process.exit(transport_pid, :kill) && Process.sleep(10)
      assert Tracker.connected_socket_count(pid: pid) == 1
      Process.exit(transport_pid2, :kill) && Process.sleep(10)
      assert Tracker.connected_socket_count(pid: pid) == 0

      assert Tracker.state(pid: pid) == %{
               channel_pids: %{},
               transport_pids: %{}
             }

      assert Process.alive?(pid)
    end

    test "the linked processes die if the tracker dies", %{pid: pid} do
      transport_pid = spawn(fn -> Process.sleep(10000) end)
      socket = %Phoenix.Socket{topic: "topic", transport_pid: transport_pid}
      transport_pid2 = spawn(fn -> Process.sleep(10000) end)
      socket2 = %Phoenix.Socket{topic: "topic", transport_pid: transport_pid2}
      PushEx.Test.MockSocket.setup_config()

      assert Tracker.track_socket(socket, pid: pid) == :ok
      assert Tracker.track_socket(socket2, pid: pid) == :ok

      Process.exit(pid, :kill)
      Process.sleep(10)

      refute Process.alive?(pid)
      refute Process.alive?(transport_pid)
      refute Process.alive?(transport_pid2)
    end
  end

  defp with_tracker(_) do
    # Intentionally not linked, as this process will be killed in tests
    {:ok, pid} = GenServer.start(Tracker, [])

    on_exit(fn ->
      Process.exit(pid, :kill)
    end)

    {:ok, %{pid: pid}}
  end
end
