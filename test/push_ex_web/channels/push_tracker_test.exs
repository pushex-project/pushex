defmodule PushExWeb.PushTrackerTest do
  use ExUnit.Case, async: false
  alias PushExWeb.PushTracker

  setup do
    Application.put_env(:push_ex, PushExWeb.PushTracker, untracked_topics: [])

    :ok
  end

  describe "track/1" do
    test "the channel is tracked using the topic and configured presence id" do
      PushEx.Test.MockSocket.setup_config()

      topic = make_ref()

      assert {:ok, ref} =
               PushTracker.track(%Phoenix.Socket{
                 topic: topic,
                 channel_pid: self(),
                 id: make_ref()
               })

      assert [{"id", %{online_at: _, phx_ref: ^ref}}] = Phoenix.Tracker.list(PushTracker, topic)
    end

    test "a topic can be ignored and will not become tracked" do
      PushEx.Test.MockSocket.setup_config()

      topic = make_ref()
      Application.put_env(:push_ex, PushExWeb.PushTracker, untracked_topics: ["x", topic])

      assert {:ok, :ignored_topic} =
               PushTracker.track(%Phoenix.Socket{
                 topic: topic,
                 channel_pid: self(),
                 id: make_ref()
               })

      assert Phoenix.Tracker.list(PushTracker, topic) == []
    end
  end

  describe "listeners?/1" do
    test "false without a tracked channel" do
      refute PushTracker.listeners?(make_ref())
    end

    test "true if there is a tracked channel" do
      PushEx.Test.MockSocket.setup_config()

      topic = make_ref()
      pid = spawn(fn -> Process.sleep(10_000) end)

      assert {:ok, ref} =
               PushTracker.track(%Phoenix.Socket{
                 topic: topic,
                 channel_pid: pid,
                 id: make_ref()
               })

      assert PushTracker.listeners?(topic)

      Process.exit(pid, :shutdown) && Process.sleep(10)

      refute PushTracker.listeners?(topic)
    end

    test "true if the channel is untracked" do
      topic = make_ref()
      Application.put_env(:push_ex, PushExWeb.PushTracker, untracked_topics: ["x", topic])
      assert PushTracker.listeners?(topic)
    end

    test "true if the tracker call experiences a timeout to ensure that messages aren't missed" do
      topic = make_ref()
      refute PushTracker.listeners?(topic, 5)
      assert PushTracker.listeners?(topic, 0)
    end
  end
end
