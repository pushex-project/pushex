defmodule PushEx.Instrumentation.ShardTest do
  use ExUnit.Case, async: true

  alias PushEx.Instrumentation.Shard

  describe "name_for_number/1" do
    test "a deterministic name is chosen based on the input directly" do
      assert Shard.name_for_number(0, Shard) == :"#{Shard}_0"
      assert Shard.name_for_number(1, Shard) == :"#{Shard}_1"
      assert Shard.name_for_number(200, Test) == :"#{Test}_200"
    end
  end

  describe "start_link/1" do
    test "a Shard can start" do
      assert {:ok, pid} = Shard.start_link(name: :"TestShard_0")
      assert is_pid(pid)
    end
  end

  describe "execute/2" do
    test "a Shard asynchronously executes the given function" do
      assert {:ok, pid} = Shard.start_link(name: :"TestShard_0")
      test = self()

      Shard.execute(pid, fn ->
        assert pid == self()
        send test, :done
      end)

      assert_receive :done
    end
  end
end
