defmodule TestFrontendSocket.PushInstrumenter do
  @behaviour PushEx.Behaviour.PushInstrumentation

  require Logger

  def delivered(%PushEx.Push{} = push, ctx) do
    Logger.debug("#{__MODULE__} delivered #{inspect(push)} #{inspect(ctx)}")
  end

  def requested(%PushEx.Push{} = push, ctx) do
    Logger.debug("#{__MODULE__} requested #{inspect(push)} #{inspect(ctx)}")
  end

  def api_requested(ctx) do
    Logger.debug("#{__MODULE__} controller requested #{inspect(ctx)}")
  end

  def api_processed(ctx) do
    Logger.debug("#{__MODULE__} controller processed #{inspect(ctx)}")
  end
end
