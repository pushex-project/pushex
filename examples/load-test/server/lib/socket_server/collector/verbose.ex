defmodule SocketServer.Collector.Verbose do
  def collect() do
    [
      PushEx.Instrumentation.Tracker.connected_socket_count(),
      PushEx.Instrumentation.Tracker.connected_channel_count()
    ]
  end
end
