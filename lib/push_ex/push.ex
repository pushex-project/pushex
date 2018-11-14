defmodule PushEx.Push do
  @moduledoc """
  Push data that should be delivered to a given channel/event.
  """

  @type t :: %PushEx.Push{
          channel: bitstring(),
          data: any(),
          event: bitstring(),
          unix_ms: non_neg_integer()
        }

  @enforce_keys [:channel, :data, :event, :unix_ms]
  defstruct @enforce_keys
end
