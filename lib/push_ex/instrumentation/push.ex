defmodule PushEx.Instrumentation.Push do
  alias PushEx.Push

  defmodule Behaviour do
    @doc """
    Called when a push is requested to be sent. By default this happens in the API controller.
    """
    @callback requested(%Push{}) :: any

    @doc """
    Called when a push is delivered to a Channel. This can occur more, less, or the same number of times as a push
    being requested.
    """
    @callback delivered(%Push{}) :: any

    @doc """
    Called when an API request is started.
    """
    @callback api_requested() :: any

    @doc """
    Called immediately before an API response is delivered.
    """
    @callback api_processed() :: any
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
