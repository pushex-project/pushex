defmodule PushExWeb.PushTracker do
  @behaviour Phoenix.Tracker

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  def start_link(opts) do
    opts =
      opts
      |> Keyword.put(:name, __MODULE__)
      |> Keyword.put(:pubsub_server, PushEx.PubSub)
      |> Keyword.merge(Application.get_env(:push_ex, __MODULE__) || [])

    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
  end

  def handle_diff(_diff, state) do
    {:ok, state}
  end

  def track(%Phoenix.Socket{topic: topic} = socket) do
    if topic in PushEx.Config.untracked_push_tracker_topics() do
      {:ok, :ignored_topic}
    else
      id = PushEx.Config.socket_impl().presence_identifier(socket)

      Phoenix.Tracker.track(__MODULE__, socket.channel_pid, topic, id, %{
        online_at: PushEx.unix_ms_now()
      })
    end
  end

  def listeners?(topic, timeout \\ 5000) do
    if topic in PushEx.Config.untracked_push_tracker_topics() do
      true
    else
      try do
        list_topic_state(topic, timeout)
        |> Enum.any?()
      catch
        :exit, {:timeout, _} ->
          true
      end
    end
  end

  defp list_topic_state(topic, timeout) do
    __MODULE__
    |> Phoenix.Tracker.Shard.name_for_topic(topic, pool_size())
    |> GenServer.call({:list, topic}, timeout)
    |> Phoenix.Tracker.State.get_by_topic(topic)
  end

  defp pool_size() do
    [{:pool_size, size}] = :ets.lookup(__MODULE__, :pool_size)
    size
  end
end
