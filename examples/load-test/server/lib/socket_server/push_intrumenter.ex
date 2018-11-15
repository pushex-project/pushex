defmodule SocketServer.PushInstrumenter do
  @behaviour PushEx.Behaviour.PushInstrumentation

  require Logger

  def delivered(%PushEx.Push{} = push) do
    Logger.debug("#{__MODULE__} delivered #{inspect(push)} at #{PushEx.unix_ms_now()}")
  end

  def requested(%PushEx.Push{} = push) do
    Logger.debug("#{__MODULE__} requested #{inspect(push)} at #{PushEx.unix_ms_now()}")
  end

  def api_requested() do
    Logger.debug("#{__MODULE__} controller requested")
  end

  def api_processed() do
    Logger.debug("#{__MODULE__} controller processed")
  end
end
