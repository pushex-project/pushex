defmodule PushEx.Instrumentation.PushTest do
  use ExUnit.Case, async: false

  alias PushEx.{Instrumentation, Push}

  @push %Push{
    channel: "c",
    event: "e",
    data: "d"
  }

  describe "requested/1" do
    test "can work without any instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 0)
      Instrumentation.Push.requested(@push)
      assert PushEx.Test.MockInstrumenter.state().requested == []
    end

    test "sends the push to all instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 2)
      Instrumentation.Push.requested(@push)
      assert PushEx.Test.MockInstrumenter.state().requested == [[@push], [@push]]
    end
  end

  describe "delivered/1" do
    test "can work without any instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 0)
      Instrumentation.Push.delivered(@push)
      assert PushEx.Test.MockInstrumenter.state().delivered == []
    end

    test "sends the push to all instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 2)
      Instrumentation.Push.delivered(@push)
      assert PushEx.Test.MockInstrumenter.state().delivered == [[@push], [@push]]
    end
  end

  describe "api_requested/1" do
    test "can work without any instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 0)
      Instrumentation.Push.api_requested()
      assert PushEx.Test.MockInstrumenter.state().api_requested == []
    end

    test "sends the push to all instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 2)
      Instrumentation.Push.api_requested()
      assert PushEx.Test.MockInstrumenter.state().api_requested == [[], []]
    end
  end

  describe "api_processed/1" do
    test "can work without any instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 0)
      Instrumentation.Push.api_processed()
      assert PushEx.Test.MockInstrumenter.state().api_processed == []
    end

    test "sends the push to all instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 2)
      Instrumentation.Push.api_processed()
      assert PushEx.Test.MockInstrumenter.state().api_processed == [[], []]
    end
  end
end
