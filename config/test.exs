use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :push_ex, PushExWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :debug
