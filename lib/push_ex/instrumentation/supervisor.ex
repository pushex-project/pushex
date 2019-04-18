defmodule PushEx.Instrumentation.Supervisor do
  @moduledoc false

  use Supervisor

  alias PushEx.Instrumentation.Shard

  def shard_for_time(time, opts \\ []) when time >= 0 do
    prefix = Keyword.get(opts, :prefix, Shard)
    num_shards = Keyword.get(opts, :pool_size, pool_size())

    time
    |> rem(num_shards)
    |> Shard.name_for_number(prefix)
    |> Process.whereis()
  end

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    shard_prefix = Keyword.get(opts, :prefix, Shard)
    num_shards = Keyword.get(opts, :pool_size, pool_size())

    shards =
      for n <- 0..(num_shards - 1) do
        shard_name = Shard.name_for_number(n, shard_prefix)
        worker(Shard, [[name: shard_name]], id: shard_name)
      end

    supervise(shards, strategy: :one_for_one)
  end

  defp pool_size(), do: PushEx.Application.pool_size()
end
