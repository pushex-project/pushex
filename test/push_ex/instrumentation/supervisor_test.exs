defmodule PushEx.Instrumentation.SupervisorTest do
  use ExUnit.Case, async: true

  alias PushEx.Instrumentation.Supervisor

  describe "start_link/1" do
    test "it can be started", %{test: test} do
      assert {:ok, pid} = Supervisor.start_link(prefix: test)
    end
  end

  describe "shard_for_time/1" do
    test "it retrieves a shard" do
      assert pid = Supervisor.shard_for_time(0)
      assert is_pid(pid)
      assert pid == Process.whereis(:"#{PushEx.Instrumentation.Shard}_0")
    end

    test "it can accept dynamic pool sizes", %{test: test} do
      assert {:ok, pid} = Supervisor.start_link(prefix: test, pool_size: 2)

      assert pid = Supervisor.shard_for_time(0, prefix: test, pool_size: 2)
      assert is_pid(pid)
      assert pid == Process.whereis(:"#{test}_0")

      assert pid = Supervisor.shard_for_time(1, prefix: test, pool_size: 2)
      assert is_pid(pid)
      assert pid == Process.whereis(:"#{test}_1")

      assert pid = Supervisor.shard_for_time(2, prefix: test, pool_size: 2)
      assert is_pid(pid)
      assert pid == Process.whereis(:"#{test}_0")
    end
  end
end
