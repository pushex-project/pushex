# Change Log

This project adheres to [Semantic Versioning](http://semver.org/).

Every release, along with the migration instructions, is documented on the Github [Releases page](https://github.com/pushex-project/pushex/releases).

## Migration Instructions

TODO_SET_VERSION:

This release bumps Phoenix to 1.5, which comes with some breaking changes to how PubSub is configured. Everything will operate the same way, but is required to be setup differently now.

- Update your config.exs file

Remove the `pubsub` config for `config :push_ex, PushExWeb.Endpoint` and replace it with the new `pubsub_server` config:

```elixir
config :push_ex, PushExWeb.Endpoint,
  ...
  pubsub_server: PushEx.PubSub,
  ...
```

If you have a custom config in pubsub_server previously, you must update that in the new config option:

```elixir
config :push_ex, PushEx.PubSub,
  config: [adapter: Phoenix.PubSub.PG2, pool_size: 4]
```

The actual options inside of config are identical to `pubsub_server`, but you don't need to set the `name` because that's handled in code for you.
