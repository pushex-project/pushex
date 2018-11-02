defmodule TestFrontendSocket.PushInstrumenter do
  @behaviour PushEx.Instrumentation.Push.Behaviour

  require Logger

  def delivered(%PushEx.Push{} = push) do
    Logger.debug("#{__MODULE__} delivered #{inspect(push)}")
  end

  def requested(%PushEx.Push{} = push) do
    Logger.debug("#{__MODULE__} requested #{inspect(push)}")
  end
end
