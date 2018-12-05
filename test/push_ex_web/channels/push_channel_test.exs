defmodule PushExWeb.PushChannelTest do
  use PushExWeb.ChannelCase, async: false

  alias PushExWeb.{PushChannel, PushSocket}
  import ExUnit.CaptureLog

  @push %PushEx.Push{
    channel: "c",
    event: "e",
    data: "d",
    unix_ms: 0
  }

  describe "join/3" do
    test "the join function defers to the socket_impl" do
      PushEx.Test.MockSocket.setup_logging_config()

      log =
        capture_log(fn ->
          socket(PushSocket, "test", %{})
          |> subscribe_and_join(PushChannel, "c")
        end)

      assert log =~ "Replied c :ok"
      assert log =~ "LoggingSocket channel_join/3 #{inspect({"c", %{}, "socket"})}"
      assert log =~ "LoggingSocket presence_identifier/1 {socket}"
    end

    test "the channel is tracked in Instrumentation.Tracker and PushPresence" do
      assert PushEx.Instrumentation.Tracker.connected_channel_count() == 0
      refute PushExWeb.PushTracker.listeners?("c")

      PushEx.Test.MockSocket.setup_logging_config()

      capture_log(fn ->
        socket(PushSocket, "test", %{})
        |> subscribe_and_join(PushChannel, "c")

        Process.sleep(20)
      end)

      assert PushEx.Instrumentation.Tracker.connected_channel_count() == 1
      assert PushExWeb.PushTracker.listeners?("c")
    end

    test "the channel can be error'd, which prevents tracking" do
      assert PushEx.Instrumentation.Tracker.connected_channel_count() == 0
      PushEx.Test.MockSocket.setup_config(:channel_fail)

      assert capture_log(fn ->
               assert socket(PushSocket, "test", %{})
                      |> subscribe_and_join(PushChannel, "c") == {:error, %{reason: "unauthorized"}}

               Process.sleep(20)
             end) =~ "Replied c :error"

      assert PushEx.Instrumentation.Tracker.connected_channel_count() == 0
      refute PushExWeb.PushTracker.listeners?("c")
    end
  end

  describe "broadcast/2, without listeners" do
    test "no broadcast occurs" do
      assert PushChannel.broadcast({:msg, "c"}, @push) == {:ok, :no_listeners}
    end
  end

  describe "broadcast/2, with listeners" do
    test "the message is broadcast out" do
      PushEx.Test.MockSocket.setup_config()

      capture_log(fn ->
        socket(PushSocket, "test", %{})
        |> subscribe_and_join(PushChannel, "c")
      end)

      Process.sleep(10)

      assert PushChannel.broadcast({:msg, "c"}, @push) == {:ok, :broadcast}
      assert_broadcast "msg", @push
    end

    test "the endpoint can be customized" do
      PushEx.Test.MockSocket.setup_config()

      capture_log(fn ->
        socket(PushSocket, "test", %{})
        |> subscribe_and_join(PushChannel, "c")
      end)

      Process.sleep(10)

      assert capture_log(fn ->
               assert PushChannel.broadcast({:msg, "c"}, @push, endpoint: PushEx.Test.MockEndpoint) == {:ok, :broadcast}
             end) =~ "MockEndpoint broadcast!/3 #{inspect({"c", "msg", @push})}"
    end
  end

  describe "handle_out msg" do
    test "the push is sent to the socket" do
      PushEx.Test.MockSocket.setup_config()
      PushEx.Test.MockInstrumenter.setup_config()

      capture_log(fn ->
        {:ok, _, socket} =
          socket(PushSocket, "test", %{})
          |> subscribe_and_join(PushChannel, "c")

        broadcast_from!(socket, "msg", @push)
        output = %{data: "d", event: "e"}
        assert_push("msg", ^output)
      end)

      assert PushEx.Test.MockInstrumenter.state().delivered == [[@push, :ctx]]
    end
  end
end
