# Instrumentation

Several hooks are provided to gather information about the execution of your PushEx server. These are provided by `PushEx.Behaviour.PushInstrumentation` and are configured by using:

```elixir
# Note that you can set multiple listeners by including multiple in the list.
config :push_ex, PushEx.Instrumentation, push_listeners: [DemoApp.PushInstrumenter]
```

Be careful with how you are handling your push logging. There could be sensitive information in the payload, and the payload could be quite large. If logging out every push / API call to disk or another logging service, it would be very easy to send a large amount of bytes very quickly.

## Context

Each instrumentation includes a `PushEx.Instrumentation.Push.Context` argument which provides information such as when the event originated. Events are processed synchronously, which means that the service could slow down if your instrumentation is expensive. You could manually switch to asynchronous in this case, although I have been bit by this approach.

## HTTP API

The instrumentation behaviour provides `api_requested/1` and `api_processed/1`. This allows you to know each time that an API call is invoked and when it finishes.

The `%Plug.Conn{}` and `params` map are currently *not* passed into this analytics function, because it could become very expensive to maintain the binaries longer than necessary. If you desire to log specific information at the controller level, you could do so in your authentication function, which receives the `%Plug.Conn{}` and `params`.

## Push Delivery

The instrumentation behaviour provides `requested/2` and `delivered/2`. `requested` is invoked with the `PushEx.Push` contents when a Push originates in the system. `delivered` is invoked with the `PushEx.Push` contents when a Push is delivered to a channel.

It is expected that requested/delivered could vary wildly from system to system. For example, it is possible to have 0 connected users but be sending pushes into the system (because your other systems don't know about who is connected). This would lead to a `requested` rate of N but a `delivered` rate of 0. Another example is that your `requested` rate is N but your `delivered` rate is N*10 because every push goes to 10 different connected channels.

## Why?

Instrumenting your system is critical for understanding how it is being used. I personally recommend sending as much information as possible to a StatsD aggregator like DataDog in order to create charts of what the requested vs delivered rate is, or what the throughput of your API is.
