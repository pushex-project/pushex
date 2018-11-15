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

config :push_ex, PushEx.Instrumentation, push_listeners: [TestFrontendSocket.PushInstrumenter]

config :push_ex, PushExWeb.PushSocket, socket_impl: TestFrontendSocket

config :push_ex, PushExWeb.PushController, controller_impl: TestFrontendSocket
