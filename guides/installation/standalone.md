# Installation - Standalone

PushEx is an implementation of Phoenix websockets/channels which handles best practices of running websockets for you, but allows your business logic to be specified through simple behaviour modules.

This guide will go through the steps necessary to create a standalone deployment of PushEx tailored to your business needs, from start to finish.

## Why Standalone?

A standalone installation is preferred and is how I would run any serious push service. This is because push services change very infrequently and so should not be deployed often. Each deploy causes reconnection of current sockets and a slight miss of messages in that time. Having a standalone service also allows for easier scaling, as new nodes can be added to the cluster quickly to meet your push capacity needs.

## Pre-installation

Ensure that your Elixir is version >= 1.12 and that your Erlang is >= OTP24:

```
elixir --version
Erlang/OTP 24 [erts-12.0.3] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1]
Elixir 1.12.3 (compiled with Erlang/OTP 24)
```

You can attempt installation without this, check the `.github/workflows/elixir.yml` file
to see the test matrix that's supported. Generally, we only support the most recent versions
depending on the needs of Phoenix / Elixir.

## Instructions

1. Create a new supervised mix application

```
mix new demo_app --sup && cd demo_app
```

2. Install the latest push_ex release (see main README) and `mix deps.get`

```
  # mix.exs

  defp deps do
    [
      {:push_ex, "FROM README"}
    ]
  end
```

3. Add `PushEx` to your Application children:

```
 # my_app/application.ex

 ...
 children = [
   ...
  PushEx,
 ]
 ...
```

This step helps ensure that you can start PushEx in the correct location. For instance, you may
want to start it after Statix boots if you are using StatsD instrumentation.

4. Setup required options in config.exs

```
use Mix.Config

# Configures the endpoint, these are Phoenix Endpoint options
config :push_ex, PushExWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PushExWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: PushEx.PubSub,
  http: [port: 4004],
  check_origin: false,
  watchers: [],
  server: true

# Set the pool size to the number of cores of your server
config :push_ex, PushEx.PubSub,
  adapter: Phoenix.PubSub.PG2,
  pool_size: 4

# Configures Elixir's Logger (vary based on deployment environment)
config :logger, :console,
  level: :error,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :push_ex, PushEx.Instrumentation, push_listeners: [DemoApp.PushInstrumenter]

config :push_ex, PushExWeb.PushSocket, socket_impl: DemoApp.Socket

config :push_ex, PushExWeb.PushController, controller_impl: DemoApp.Controller
```

5. Implement Socket, Controller, Instrumentation modules

```
# demo_app/socket.ex

defmodule DemoApp.Socket do
  @behaviour PushEx.Behaviour.Socket

  def socket_connect(_params, socket) do
    {:ok, socket}
  end

  def socket_id(_socket) do
    "id"
  end

  def presence_identifier(socket) do
    socket_id(socket)
  end

  def channel_join(_channel, _params, socket) do
    {:ok, socket}
  end
end
```

```
# demo_app/controller.ex

defmodule DemoApp.Controller do
  @behaviour PushEx.Behaviour.Controller

  def auth(_conn, _params) do
    :ok
  end
end
```

```
# demo_app/push_instrumenter.ex

defmodule DemoApp.PushInstrumenter do
  @behaviour PushEx.Behaviour.PushInstrumentation

  require Logger

  def delivered(%PushEx.Push{} = push, ctx) do
    Logger.debug("#{__MODULE__} delivered #{inspect(push)} #{inspect(ctx)}")
  end

  def requested(%PushEx.Push{} = push, ctx) do
    Logger.debug("#{__MODULE__} requested #{inspect(push)} #{inspect(ctx)}")
  end

  def api_requested(ctx) do
    Logger.debug("#{__MODULE__} controller requested #{inspect(ctx)}")
  end

  def api_processed(ctx) do
    Logger.debug("#{__MODULE__} controller processed #{inspect(ctx)}")
  end
end
```

6. Implement your custom application logic

It's crucial that your application ships with proper authentication logic, or anyone could access sensitive information over your sockets. This may be fine if you're pushing data down to all users of a marketing site, but would be unacceptable in any environment with separate users.

PushEx behaviours are all documented with their types. It is possible to fully customize the flow of the system using these behaviours. An example of this is accepting a JWT on `socket_connect` + `channel_join` and enforcing that the JWT is valid and matches private channel claims.

Instrumentation can be used to gather insights into the running system, but is completely optional.

7. Deploy / Monitor your app as normal

The app that you've created is a normal Elixir app. This means that you can utilize your normal deployment / monitoring solutions without much additional ceremony. You can run your app locally by using:

```bash
mix run --no-halt
```

You can read more about deployment in the [Deployment](/deployment.html) guide.

If you deploy your app as a cluster, it is important that the nodes are able to communicate with each other. If they cannot, then the PG2 system will not work and you will receive missed messages. You can read about different clustering solutions in the [Phoenix PubSub](/pub_sub.html) guide.
