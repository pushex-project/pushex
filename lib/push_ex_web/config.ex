defmodule PushExWeb.Config do
  @moduledoc false

  use GenServer

  def close_connections?() do
    :ets.lookup(__MODULE__, :close_connections?)
    |> Keyword.get(:close_connections?, false)
  end

  def close_connections!(bool) when is_boolean(bool) do
    GenServer.call(__MODULE__, {:close_connections, bool})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :ets.new(__MODULE__, [:set, :named_table, read_concurrency: true])
    {:ok, {}}
  end

  def handle_call({:close_connections, bool}, _, state) do
    :ets.insert(__MODULE__, {:close_connections?, bool})
    {:reply, bool, state}
  end
end
