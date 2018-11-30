defmodule PushEx.Instrumentation.Push do
  @moduledoc false

  defmodule Context do
    @moduledoc """
    Generic information about the instrumentation event.
    """

    @type t :: %PushEx.Instrumentation.Push.Context{
      unix_ms_occurred_at: non_neg_integer()
    }

    @enforce_keys [:unix_ms_occurred_at]
    defstruct @enforce_keys

    @doc false
    def new() do
      %__MODULE__{
        unix_ms_occurred_at: PushEx.unix_ms_now()
      }
    end
  end

  alias PushEx.{Config, Push}

  def requested(push = %Push{}) do
    ctx = Context.new()

    Config.push_listeners()
    |> Enum.each(& &1.requested(push, ctx))
  end

  def delivered(push = %Push{}) do
    ctx = Context.new()

    Config.push_listeners()
    |> Enum.each(& &1.delivered(push, ctx))
  end

  def api_requested() do
    ctx = Context.new()

    Config.push_listeners()
    |> Enum.each(& &1.api_requested(ctx))
  end

  def api_processed() do
    ctx = Context.new()

    Config.push_listeners()
    |> Enum.each(& &1.api_processed(ctx))
  end
end
