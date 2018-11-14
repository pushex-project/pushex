defmodule PushEx.Test.MockSocket do
  @behaviour PushEx.Behaviour.Socket

  def setup_config do
    Application.put_env(:push_ex, PushExWeb.PushSocket, socket_impl: __MODULE__)
  end

  def setup_config(:channel_fail) do
    Application.put_env(:push_ex, PushExWeb.PushSocket, socket_impl: PushEx.Test.MockSocket.ChannelFailSocket)
  end

  def setup_logging_config do
    Application.put_env(:push_ex, PushExWeb.PushSocket, socket_impl: PushEx.Test.MockSocket.LoggingSocket)
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

  defmodule LoggingSocket do
    @behaviour PushEx.Behaviour.Socket
    require Logger

    def socket_connect(params, socket) do
      Logger.debug "LoggingSocket socket_connect/2 #{inspect({params, "socket"})}"
      {:ok, socket}
    end

    def channel_join(channel, params, socket) do
      Logger.debug "LoggingSocket channel_join/3 #{inspect({channel, params, "socket"})}"
      {:ok, socket}
    end

    def socket_id(_socket) do
      Logger.debug "LoggingSocket socket_id/1 {socket}"
      "id"
    end

    def presence_identifier(_socket) do
      Logger.debug "LoggingSocket presence_identifier/1 {socket}"
      "id"
    end
  end

  defmodule ChannelFailSocket do
    @behaviour PushEx.Behaviour.Socket
    require Logger

    def socket_connect(_, socket) do
      {:ok, socket}
    end

    def channel_join(_, _, _) do
      {:error, %{reason: "unauthorized"}}
    end

    def socket_id(_socket) do
      "id"
    end

    def presence_identifier(_socket) do
      "id"
    end
  end
end
