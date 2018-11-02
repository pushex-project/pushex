use Mix.Config

# Configures the endpoint
config :push_ex, PushExWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PushExWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: PushEx.PubSub, adapter: Phoenix.PubSub.PG2],
  http: [port: 4004],
  check_origin: false,
  watchers: [],
  server: System.get_env("SKIP_SERVER") != "true"

# Configures Elixir's Logger
config :logger, :console,
  level: :debug,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :push_ex, PushEx.Instrumentation,
  push_listeners: [TestFrontendSocket.PushInstrumenter]

config :push_ex, PushExWeb.PushSocket,
  connect_fn: &TestFrontendSocket.socket_connect/2,
  join_fn: &TestFrontendSocket.channel_join/3,
  id_fn: &TestFrontendSocket.socket_id/1,
  presence_identifier_fn: &TestFrontendSocket.presence_identifier_fn/1

config :push_ex, PushExWeb.PushController,
  auth_fn: &TestFrontendSocket.controller_auth_fn/2
