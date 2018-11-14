defmodule PushEx.Push do
  @moduledoc """
  Push data that should be delivered to a given channel/event.
  """

  @type t :: %PushEx.Push{
          channel: bitstring(),
          data: any(),
          event: bitstring()
        }

  @enforce_keys [:channel, :data, :event]
  defstruct @enforce_keys
end
