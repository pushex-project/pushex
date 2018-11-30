defmodule PushExWeb.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :push_ex

  @heroku_timeout_accommodation 45_000

  socket "/push_socket", PushExWeb.PushSocket,
    websocket: [timeout: @heroku_timeout_accommodation],
    longpoll: false

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug PushExWeb.Router
end
