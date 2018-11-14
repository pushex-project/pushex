defmodule PushEx.Instrumentation.Push do
  @moduledoc false

  alias PushEx.{Config, Push}

  @behaviour PushEx.Behaviour.PushInstrumentation

  def requested(push = %Push{}) do
    Config.push_listeners()
    |> Enum.each(& &1.requested(push))
  end

  def delivered(push = %Push{}) do
    Config.push_listeners()
    |> Enum.each(& &1.delivered(push))
  end

  def api_requested() do
    Config.push_listeners()
    |> Enum.each(& &1.api_requested())
  end

  def api_processed() do
    Config.push_listeners()
    |> Enum.each(& &1.api_processed())
  end
end
