defmodule PushExTest do
  use ExUnit.Case, async: false

  describe "push/1" do
    setup :with_instrumentation

    test "Push.Instrumentation requested is invoked" do
      push = %PushEx.Push{channel: "c", event: "e", data: "d"}
      PushEx.push(push)

      assert PushEx.Test.MockInstrumenter.state().requested == [[push]]
    end

    test "ItemProducer receives the push" do
      pid = Process.whereis(PushEx.Push.ItemProducer)
      :erlang.trace(pid, true, [:receive])

      push = %PushEx.Push{channel: "c", event: "e", data: "d"}
      PushEx.push(push)

      assert_receive {:trace, ^pid, :receive, {:"$gen_cast", {:notify, ^push}}}
    end
  end

  describe "unix_now/0" do
    test "is a 10 digit integer" do
      assert PushEx.unix_now()
             |> Integer.digits()
             |> length() == 10
    end
  end

  defp with_instrumentation(_) do
    PushEx.Test.MockInstrumenter.setup_config()

    :ok
  end
end
