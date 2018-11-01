defmodule PushEx.Instrumentation.Tracker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{
      count: 0,
      pids: %{}
    }}
  end

  def track_socket(socket = %Phoenix.Socket{}) do
    GenServer.call(__MODULE__, {:track, socket})
  end

  def state() do
    GenServer.call(__MODULE__, :state)
  end

  ## Callbacks

  def handle_call({:track, socket = %Phoenix.Socket{channel_pid: pid, topic: topic}}, _from, state = %{count: count, pids: pids}) do
    id = PushEx.Config.presence_identifier_fn().(socket)
    Process.monitor(pid)

    new_pids = Map.put(pids, pid, %{
      channel: topic,
      identifier: id,
      online_at: PushEx.unix_now(),
    })

    {:reply, :ok, %{state | pids: new_pids, count: count + 1}}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state = %{count: count, pids: pids}) do
    new_pids = Map.delete(pids, pid)
    {:noreply, %{state  | pids: new_pids, count: count - 1}}
  end
end
