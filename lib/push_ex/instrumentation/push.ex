defmodule PushEx.Instrumentation.Push do
  alias PushEx.Push

  defmodule Behaviour do
    @callback requested(%Push{}) :: any
    @callback delivered(%Push{}) :: any
  end

  @behaviour Behaviour

  def requested(push = %Push{}) do
    listeners()
    |> Enum.each(& &1.requested(push))
  end

  def delivered(push = %Push{}) do
    listeners()
    |> Enum.each(& &1.delivered(push))
  end

  defp listeners() do
    Application.get_env(:push_ex, PushEx.Instrumentation, [])
    |> Keyword.get(:push_listeners, [])
  end
end