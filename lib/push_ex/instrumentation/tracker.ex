defmodule PushEx.Instrumentation.Tracker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.flag(:trap_exit, true)

    {:ok,
     %{
       channel_pids: %{},
       transport_pids: %{}
     }}
  end

  def track_channel(socket = %Phoenix.Socket{}) do
    GenServer.call(__MODULE__, {:track, socket})
  end

  def track_socket(socket = %Phoenix.Socket{}) do
    GenServer.call(__MODULE__, {:track_socket, socket})
  end

  def state() do
    GenServer.call(__MODULE__, :state)
  end

  ## Callbacks

  def handle_call(
        {:track, socket = %Phoenix.Socket{channel_pid: pid, topic: topic}},
        _from,
        state = %{channel_pids: pids}
      ) do
    link_processes_to_capture_bidirectional_exits(pid)

    id = PushEx.Config.presence_identifier_fn().(socket)
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

    id = PushEx.Config.presence_identifier_fn().(socket)
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
