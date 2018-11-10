defmodule PushEx.SocketBehaviour do
  @callback socket_connect(map(), Phoenix.Socket.t()) :: any
  @callback channel_join(bitstring(), map(), Phoenix.Socket.t()) :: any
  @callback socket_id(Phoenix.Socket.t()) :: any
  @callback presence_identifier(Phoenix.Socket.t()) :: any
end
