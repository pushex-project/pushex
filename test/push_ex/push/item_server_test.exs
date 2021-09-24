defmodule PushEx.Push.ItemServerTest do
  use ExUnit.Case, async: false

  alias PushEx.Push.ItemServer
  import ExUnit.CaptureLog

  @push %PushEx.Push{
    channel: "c",
    event: "e",
    data: "d",
    unix_ms: 0
  }

  defmodule MockChannelApi do
    require Logger

    def broadcast({:msg, channel}, item) do
      Logger.debug(inspect({{:msg, channel}, item}))
      {:ok, :broadcast}
    end
  end

  describe "start_link/1" do
    test "a process is started that successfully completes, without mocks" do
      assert capture_log(fn ->
               assert {:ok, _pid} = ItemServer.start_link(%{item: @push, at: 1})
               Process.sleep(20)
             end) =~ "[debug] Push.ItemServer no_listeners channel=c event=e ms_in_stage="
    end

    test "a mock channel API shows the call type" do
      log =
        capture_log(fn ->
          assert {:ok, _pid} = ItemServer.start_link(%{item: @push, at: 1}, channel_api_mod: MockChannelApi)
          Process.sleep(50)
        end)

      assert log =~ "[debug] Push.ItemServer broadcast channel=c event=e ms_in_stage="
      assert log =~ "[debug] #{inspect({{:msg, "c"}, @push})}"
    end
  end
end
