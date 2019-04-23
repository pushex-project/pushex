# Public Topics

A single topic which every client connects to is typically very expensive to track in a cluster. This
is because the sharding algorithm works based on the `topic` value and the same topic will always be
sharded the same way. This can cause a single shard to become "hot" and receive a bulk of work.

If there is a public topic, it most likely is always going to have a connection to it. We therefore can
treat it as always having a connection and not check if there is actively a connection. PushEx allows
you to configure this using the `untracked_topics` configuration of `PushExWeb.PushTracker`.

You can set it up like this:

```elixir
config :push_ex, PushExWeb.PushTracker,
  untracked_topics: ["my-public-channel", "other-public-channel"]
```

The topic will appear in the `Pushex.Instrumentation.Tracker` but not in `PushExWeb.PushTracker`.
