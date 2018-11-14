defmodule PushExWeb.PushSocketTest do
  use PushExWeb.ChannelCase, async: false
  alias PushExWeb.PushSocket

  import ExUnit.CaptureLog

  describe "connect/2" do
    test "the connection logic defers to the socket_impl" do
      PushEx.Test.MockSocket.setup_logging_config()

      log =
        capture_log(fn ->
          assert {:ok, socket} = connect(PushSocket, %{})
        end)

      assert log =~ "Replied PushExWeb.PushSocket :ok"
      assert log =~ "LoggingSocket socket_connect/2 #{inspect({%{}, "socket"})}"
      assert log =~ "LoggingSocket socket_id/1 {socket}"
      assert log =~ "LoggingSocket presence_identifier/1 {socket}"
      assert String.split(log, "LoggingSocket") |> length() == 4
    end

    test "the socket is tracked in the global tracker" do
      PushEx.Test.MockSocket.setup_config()

      assert PushEx.Instrumentation.Tracker.state() == %{
               channel_pids: %{},
               transport_pids: %{}
             }

      capture_log([level: :info], fn ->
        assert {:ok, socket} = connect(PushSocket, %{})
        Process.sleep(10)

        transport_pid = socket.transport_pid
        empty_map = %{}

        assert %{
          channel_pids: ^empty_map,
          transport_pids: %{
            ^transport_pid => %{
              identifier: "id",
              online_at: _,
              type: :channel_test
            }
          }
        } = PushEx.Instrumentation.Tracker.state()
      end)
    end
  end
end
