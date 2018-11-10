defmodule PushEx.Behaviour.Controller do
  @moduledoc """
  Implementable functions that are used by the API controller. It is crucial to ensure that all API calls are secured behind proper auth.
  """

  @doc """
  Accepts a Plug.Conn and params map to determine if the API is allowed to be accessed. It is possible to modify
  the response Plug.Conn completely, or return simple `:ok | :error` atoms.
  """
  @callback auth(Plug.Conn.t(), map()) :: :ok | {:ok, Plug.Conn.t(), map()} | :error | {:error, Plug.Conn.t()}
end
