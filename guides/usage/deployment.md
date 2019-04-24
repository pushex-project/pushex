# Deployment

Congrats on making it this far, you're ready to deploy! This is one of the final steps and the start of having a great push server at your disposal, but make sure to not cut any corners here.

PushEx can be deployed like any other Elixir application. If you have experience deploying an Elixir application, then you should most likely follow what you're familiar with. If you have no experience deploying an Elixir application, then I'm hoping to help you out here with some general recommendations!

This guide will not go from A->B of shipping a server, but will give you some pointers on how to go about it. There are a lot of tutorials out there on shipping Elixir applications, and there should be no difference between this and other deployments.

## Shipping "Releases"

It is highly recommended in the Elixir community to use [Distillery](https://github.com/bitwalker/distillery) to build and ship releases of your application. These releases give you some benefits such as:

* No source code necessary on the deployment
* `remote_console` command to connect to running nodes easily
* Faster boot because the application is already compiled

It is recommended to use Distillery for PushEx for these reasons. It is not necessary, but again is highly recommended.

## On Heroku

Phoenix has an excellent [Heroku Guide](https://hexdocs.pm/phoenix/heroku.html) which walks through releasing an application on Heroku. Most of the changes are at the config.exs level (which you provide fully) and the 45s websocket timeout accommodation has been added by default to PushEx.

You should be very careful about [Heroku's connection limits](http://veldstra.org/2013/10/25/heroku-websocket-performance-test.html) as they could spell disaster for a server like PushEx. This is because websocket connections can only be made at a rate of ~150 conn/s and a single server can only have ~6000 conns. If you had 6000 connections on 1 server and it rebooted while all connections were active, it would take over 40s to reconnect everyone!

## PubSub

Please follow the [PubSub guide](/pub_sub.html) in order to configure PubSub for your deployment. Note that you must use the Redis adapter for PubSub if deploying to Heroku.

## Taking a Node Offline

You may or may not be taking Nodes offline for deployments. I am doing so with Kubernetes and Heroku also requires
restarting for deployments. PushEx tries to handle a lot of this for you by providing exit listeners for the web
server and for the Push.ItemProducer data pipeline. Each item is given 10 seconds to complete (20s) total. This
should minimize the likelihood of a process being offline but connections still trying to use the process.

Sockets can be disconnected when the server is brought offline. This is *not* performed by default as it
could be the wrong thing to do in certain environments. It is easy to turn on this option with a configuration:

```elixir
config :push_ex, PushExWeb.PushSocket,
  socket_impl: TestFrontendSocket,
  disconnect_sockets_on_shutdown: true
```

Local socket transports will be sent a disconnect broadcast. The client will automatically start reconnecting
to establish the connection. It is important that your load balancer does not send any new connections to the
old node or they will fail because the web server will not accept new connections.

## Recommendations

Every company will be different with regards to how they deploy application: docker, amazon, google, heroku, kubernetes, the list goes on. Therefore, it's impossible to make a direct recommendation of what you should do when deploying PushEx. However, I can caution that Heroku will most likely be a bad choice for large applications and instead you should consider other routes.

There will likely be deployment templates over time as the community requests it and the need arises. Please reach out in an issue if you have any questions about deployment.
