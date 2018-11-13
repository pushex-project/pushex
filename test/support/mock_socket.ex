defmodule PushEx.Test.MockSocket do
  @behaviour PushEx.Behaviour.Socket

  def setup_config do
    Application.put_env(:push_ex, PushExWeb.PushSocket, socket_impl: __MODULE__)
  end

  def socket_connect(_, socket) do
    {:ok, socket}
  end

  def channel_join(_, _, socket) do
    {:ok, socket}
  end

  def socket_id(_socket) do
    "id"
  end

  def presence_identifier(_socket) do
    "id"
  end
end
