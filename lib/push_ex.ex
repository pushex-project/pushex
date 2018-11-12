defmodule PushEx do
  @moduledoc """
  PushEx context exposes functions related to the core competency of PushEx, enqueueing pushes.
  """

  alias PushEx.Push
  alias PushEx.Instrumentation
  alias Push.ItemProducer

  @doc """
  Triggers a Push to be instrumented/enqueued into the system
  """
  @spec push(%Push{}) :: true
  def push(item = %Push{}) do
    Instrumentation.Push.requested(item)
    ItemProducer.push(item)
    true
  end

  @doc false
  def unix_now(), do: (:erlang.system_time() / 1_000_000_000) |> round()
end
