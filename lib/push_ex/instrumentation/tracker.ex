defmodule PushEx.Instrumentation.Tracker do
  @moduledoc """
  GenServer that tracks channels and transports to keep track of how many sockets/channels are connected currently.
  All tracking is for the current node only. Presence must be used for full-cluster tracking.
  """

  use GenServer

  @doc false
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init(_) do
    Process.flag(:trap_exit, true)

    {:ok, %{channel_pids: %{}, transport_pids: %{}}}
  end

  @doc """
  Returns the number of sockets (transports) connected to this node.
  """
  @spec connected_socket_count() :: non_neg_integer()
  def connected_socket_count(opts \\ []) do
    pid = Keyword.get(opts, :pid, __MODULE__)
    GenServer.call(pid, :connected_socket_count)
  end

  @doc """
  Returns the number of channels connected to this node.
  """
  @spec connected_channel_count() :: non_neg_integer()
  def connected_channel_count(opts \\ []) do
    pid = Keyword.get(opts, :pid, __MODULE__)
    GenServer.call(pid, :connected_channel_count)
  end

  @doc false
  def track_channel(socket = %Phoenix.Socket{}, opts \\ []) do
    pid = Keyword.get(opts, :pid, __MODULE__)
    GenServer.call(pid, {:track, socket})
  end

  @doc false
  def track_socket(socket = %Phoenix.Socket{}, opts \\ []) do
    pid = Keyword.get(opts, :pid, __MODULE__)
    GenServer.call(pid, {:track_socket, socket})
  end

  @doc false
  def state(opts \\ []) do
    pid = Keyword.get(opts, :pid, __MODULE__)
    GenServer.call(pid, :state)
  end

  ## Callbacks

  def handle_call(:connected_channel_count, _from, state = %{channel_pids: pids}) do
    {:reply, map_size(pids), state}
  end

  def handle_call(:connected_socket_count, _from, state = %{transport_pids: pids}) do
    {:reply, map_size(pids), state}
  end

  def handle_call(
        {:track, socket = %Phoenix.Socket{channel_pid: pid, topic: topic}},
        _from,
        state = %{channel_pids: pids}
      ) do
    link_processes_to_capture_bidirectional_exits(pid)

    id = PushEx.Config.socket_impl().presence_identifier(socket)
    online_at = PushEx.unix_now()

    new_channel_pids =
      Map.put(pids, pid, %{
        channel: topic,
        identifier: id,
        online_at: online_at
      })

    {:reply, :ok, %{state | channel_pids: new_channel_pids}}
  end

  def handle_call(
        {:track_socket, socket = %Phoenix.Socket{transport: transport, transport_pid: transport_pid}},
        _from,
        state = %{transport_pids: transport_pids}
      ) do
    link_processes_to_capture_bidirectional_exits(transport_pid)

    id = PushEx.Config.socket_impl().presence_identifier(socket)
    online_at = PushEx.unix_now()

    new_transport_pids =
      Map.put(transport_pids, transport_pid, %{
        type: transport,
        identifier: id,
        online_at: online_at
      })

    {:reply, :ok, %{state | transport_pids: new_transport_pids}}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, pid, _reason}, state = %{channel_pids: pids, transport_pids: transport_pids}) do
    new_channel_pids = Map.delete(pids, pid)
    new_transport_pids = Map.delete(transport_pids, pid)

    {:noreply, %{state | channel_pids: new_channel_pids, transport_pids: new_transport_pids}}
  end

  defp link_processes_to_capture_bidirectional_exits(pid), do: Process.link(pid)
end
