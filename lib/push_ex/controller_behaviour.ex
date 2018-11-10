defmodule PushEx.ControllerBehaviour do
  @callback auth(Plug.Conn.t(), map()) :: :ok | {:ok, Plug.Conn.t(), map()} | :error | {:error, Plug.Conn.t()}
end
