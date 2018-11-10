defmodule PushEx.Behaviour.PushInstrumentation do
  @moduledoc """
  Implements different hook in points for push lifecycle instrumentation. Callbacks are required but do not need to do anything.
  """

  alias PushEx.Push

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
