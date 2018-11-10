defmodule PushEx.Behaviour.Socket do
  @moduledoc """
  Implementable functions that are used in the flow of socket/channel creation. It is crucial to implement secure connect/join functions
  for all applications.
  """

  @doc """
  See `c:Phoenix.Socket.connect/3`
  """
  @callback socket_connect(map(), Phoenix.Socket.t()) :: {:ok, Phoenix.Socket.t()} | :error

  @doc """
  See `c:Phoenix.Channel.join/3`
  """
  @callback channel_join(bitstring(), map(), Phoenix.Socket.t()) ::
              {:ok, Phoenix.Socket.t()}
              | {:ok, reply :: map(), Phoenix.Socket.t()}
              | {:error, reason :: map()}

  @doc """
  See `c:Phoenix.Socket.id/1`s
  """
  @callback socket_id(Phoenix.Socket.t()) :: bitstring()

  @doc """
  See `c:Phoenix.Presence.track/4` `key`
  """
  @callback presence_identifier(Phoenix.Socket.t()) :: bitstring()
end
