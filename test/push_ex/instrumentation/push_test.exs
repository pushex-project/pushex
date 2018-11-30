defmodule PushEx.Instrumentation.PushTest do
  use ExUnit.Case, async: false

  alias PushEx.{Instrumentation, Push}

  @push %Push{
    channel: "c",
    event: "e",
    data: "d",
    unix_ms: 0
  }

  @mock_ctx :ctx
  @purge_process_sleep 20

  describe "requested/1" do
    test "can work without any instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 0)
      Instrumentation.Push.requested(@push)
      Process.sleep(@purge_process_sleep)
      assert PushEx.Test.MockInstrumenter.state().requested == []
    end

    test "sends the push to all instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 2)
      Instrumentation.Push.requested(@push)
      Process.sleep(@purge_process_sleep)
      assert PushEx.Test.MockInstrumenter.state().requested == [[@push, @mock_ctx], [@push, @mock_ctx]]
    end
  end

  describe "delivered/1" do
    test "can work without any instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 0)
      Instrumentation.Push.delivered(@push)
      Process.sleep(@purge_process_sleep)
      assert PushEx.Test.MockInstrumenter.state().delivered == []
    end

    test "sends the push to all instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 2)
      Instrumentation.Push.delivered(@push)
      Process.sleep(@purge_process_sleep)
      assert PushEx.Test.MockInstrumenter.state().delivered == [[@push, @mock_ctx], [@push, @mock_ctx]]
    end
  end

  describe "api_requested/1" do
    test "can work without any instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 0)
      Instrumentation.Push.api_requested()
      Process.sleep(@purge_process_sleep)
      assert PushEx.Test.MockInstrumenter.state().api_requested == []
    end

    test "sends the push to all instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 2)
      Instrumentation.Push.api_requested()
      Process.sleep(@purge_process_sleep)
      assert PushEx.Test.MockInstrumenter.state().api_requested == [[@mock_ctx], [@mock_ctx]]
    end
  end

  describe "api_processed/1" do
    test "can work without any instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 0)
      Instrumentation.Push.api_processed()
      Process.sleep(@purge_process_sleep)
      assert PushEx.Test.MockInstrumenter.state().api_processed == []
    end

    test "sends the push to all instrumentation" do
      PushEx.Test.MockInstrumenter.setup_config(count: 2)
      Instrumentation.Push.api_processed()
      Process.sleep(@purge_process_sleep)
      assert PushEx.Test.MockInstrumenter.state().api_processed == [[@mock_ctx], [@mock_ctx]]
    end
  end
end
