defmodule PushEx.Instrumentation.Push do
  @moduledoc false

  alias PushEx.Push

  @behaviour PushEx.Behaviour.PushInstrumentation

  def requested(push = %Push{}) do
    listeners()
    |> Enum.each(& &1.requested(push))
  end

  def delivered(push = %Push{}) do
    listeners()
    |> Enum.each(& &1.delivered(push))
  end

  def api_requested() do
    listeners()
    |> Enum.each(& &1.api_requested())
  end

  def api_processed() do
    listeners()
    |> Enum.each(& &1.api_processed())
  end

  defp listeners() do
    Application.get_env(:push_ex, PushEx.Instrumentation, [])
    |> Keyword.get(:push_listeners, [])
  end
end
