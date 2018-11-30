# Instrumentation

Several hooks are provided to gather information about the execution of your PushEx server. These are provided by `PushEx.Behaviour.PushInstrumentation` and are configured by using:

```elixir
config :push_ex, PushEx.Instrumentation, push_listeners: [DemoApp.PushInstrumenter]
```

Note that you can set multiple listeners by including multiple in the list.

## HTTP API

The instrumentation behaviour provides `api_requested/0` and `api_processed/0`. This allows you to know each time that an API call is invoked and when it finishes.

## Push Delivery

The instrumentation behaviour provides `requested/1` and `delivered/1`. `requested` is invoked with the `PushEx.Push` contents when a Push originates in the system. `delivered` is invoked with the `PushEx.Push` contents when a Push is delivered to a channel.

It is expected that requested/delivered could vary wildly from system to system. For example, it is possible to have 0 connected users but be sending pushes into the system (because your other systems don't know about who is connected). This would lead to a `requested` rate of N but a `delivered` rate of 0. Another example is that your `requested` rate is N but your `delivered` rate is N*10 because every push goes to 10 different connected channels.

## Why?

Instrumenting your system is critical for understanding how it is being used. I personally recommend sending as much information as possible to a StatsD aggregator like DataDog in order to create charts of what the requested vs delivered rate is, or what the throughput of your API is.
