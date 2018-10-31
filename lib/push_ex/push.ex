defmodule PushEx.Push do
  @enforce_keys [:channel, :data, :event]
  defstruct @enforce_keys
end
