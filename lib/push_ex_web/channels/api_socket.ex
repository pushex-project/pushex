defmodule PushExWeb.ApiSocket do
  use Phoenix.Socket

  # channel "room:*", PushExWeb.RoomChannel

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
