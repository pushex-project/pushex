defmodule PushExWeb.PushSocket do
  use Phoenix.Socket

  channel "*", PushExWeb.PushChannel

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
