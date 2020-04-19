# Phoenix PubSub

[Phoenix PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html) is a critical element of shipping production ready push servers, due to how persistent socket connections work.

Let's consider that there are 2 servers in production behind a load balancer and that any request can go to either of the servers. This means that "user 1" could connect to "server 1" and open a persistent websocket connection. "server 1" knows about this connection because it's local to it, but "server 2" has no knowledge of it. Our push API request comes in to "server 2" and needs delivered to "server 1". There is an inherent disconnection of information here and the two servers need bridged in order to communicate. Enter PubSub.

PubSub works by broadcasting messages between all servers in the cluster. These messages include presence information (who is connected to the system) as well as push data (send push X out). Phoenix PubSub works in a mesh network, so a server will broadcast the same message to all connected servers. This means that if you send a 10 KB push notification out and have 5 total servers, your server that receives it will send 10 KB of data to 4 other servers (40 KB total). It is important to understand how this spread works if you are experiencing large load.

## PubSub Options

PubSub provides 2 different options and your selection of the correct one is important:

* Phoenix.PubSub.PG2
* Phoenix.PubSub.Redis

PG2 uses erlang's internal message passing in order to deliver messages between nodes. Redis uses Redis's provided PubSub functionality to deliver messages.

### PG2

PG2 is useful when you are able to connect your servers together using built in `Node.connect` functionality in Elixir. There are a variety of libraries to assist in doing this, such as:

* [Peerage](https://github.com/mrluc/peerage)
* [libcluster](https://github.com/bitwalker/libcluster)

Setting this up is outside of the realm of this guide, but is advantageous over Redis if possible due to removing a single networking bottleneck.

### Redis

Redis is useful at times when you are not able to setup communication between nodes, but can setup communication to a central redis server. A great example of this is Heroku, where it is impossible to network two erlang nodes together.

Setting this up is outside of the realm of this guide, but is advantageous when you are not able to setup PG2. However, you will be left with a single networked point of failure (although Redis is very good when setup with enough capacity for your use case).

## Setup

The setup of PubSub in PushEx is done through your `config.exs` file. Since Phoenix 1.5 has been released, the PubSub is configured at the application level. You can set the config key for customization. For example, this will configure a PG2 adapter with a pool size of 4.

```elixir
config :push_ex, PushEx.PubSub,
  config: [adapter: Phoenix.PubSub.PG2, pool_size: 4]
```

Please note that pool_size is set in the above config. I recommend setting this to the number of CPUs of your server size. Doing so helps remove a performance bottle neck that occurs at very high usage.

You can setup `PubSub.Redis` by following the [module's documentation](https://github.com/phoenixframework/phoenix_pubsub_redis). You would set it up under the `config :push_ex, PushExWeb.PubSub` config. For example:

```elixir
config :push_ex, PushEx.PubSub,
  config: [adapter: Phoenix.PubSub.Redis, host: "192.168.1.100", node_name: System.get_env("NODE")]
```

## Considerations

It is possible to avoid actually setting this up and using `PG2` without networking if you have a 1 node server. However, you should be really careful if you set up a production system like this, as you would have a single point of failure. It has been demonstrated through load tests that a single server can accept a very high load, but it will vary greatly on each implementation and use case.
