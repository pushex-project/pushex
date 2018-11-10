defmodule PushEx.SocketBehaviour do
  @doc """
  See https://hexdocs.pm/phoenix/Phoenix.Socket.html#c:connect/3
  """
  @callback socket_connect(map(), Phoenix.Socket.t()) :: {:ok, Phoenix.Socket.t()} | :error

  @doc """
  See https://hexdocs.pm/phoenix/Phoenix.Channel.html#c:join/3
  """
  @callback channel_join(bitstring(), map(), Phoenix.Socket.t()) ::
              {:ok, Phoenix.Socket.t()}
              | {:ok, reply :: map(), Phoenix.Socket.t()}
              | {:error, reason :: map()}

  @doc """
  See https://hexdocs.pm/phoenix/Phoenix.Socket.html#c:id/1
  """
  @callback socket_id(Phoenix.Socket.t()) :: bitstring()

  @doc """
  See https://hexdocs.pm/phoenix/Phoenix.Presence.html#c:track/4 `key`
  """
  @callback presence_identifier(Phoenix.Socket.t()) :: bitstring()
end
