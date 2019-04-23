defmodule PushExTest do
  use ExUnit.Case, async: false

  defp push_and_sleep(push) do
    PushEx.push(push)
    Process.sleep(20)
  end

  describe "push/1" do
    setup :with_instrumentation

    test "Push.Instrumentation requested is invoked" do
      push = %PushEx.Push{channel: "c", event: "e", data: "d", unix_ms: 0}
      push_and_sleep(push)

      assert PushEx.Test.MockInstrumenter.state().requested == [[push, :ctx]]
    end

    test "ItemProducer receives the push" do
      pid = Process.whereis(PushEx.Push.ItemProducer)
      :erlang.trace(pid, true, [:receive])

      push = %PushEx.Push{channel: "c", event: "e", data: "d", unix_ms: 0}
      push_and_sleep(push)

      assert_receive {:trace, ^pid, :receive, {:"$gen_cast", {:notify, ^push}}}
    end
  end

  describe "unix_ms_now/0" do
    test "is a 13 digit integer" do
      assert PushEx.unix_ms_now()
             |> Integer.digits()
             |> length() == 13
    end
  end

  describe "connected_channel_count/0" do
    test "it is exposed" do
      assert PushEx.connected_channel_count() == 0
    end
  end

  describe "connected_socket_count/0" do
    test "it is exposed" do
      assert PushEx.connected_socket_count() == 0
    end
  end

  describe "connected_transport_pids/0" do
    test "it is exposed" do
      assert PushEx.connected_transport_pids() == []
    end
  end

  describe "connected_channel_pids/0" do
    test "it is exposed" do
      assert PushEx.connected_channel_pids() == []
    end
  end

  defp with_instrumentation(_) do
    PushEx.Test.MockInstrumenter.setup_config()

    :ok
  end
end
