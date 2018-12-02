# Custom Plug Setup

It is possible to configure the web API to use custom plug setups. This can be useful if you are using a module such as `Plugsnag` or `NewRelic` which requires inserting code like `use Plugsnag` into your router. This can also be useful if you want to expose custom HTTP endpoints on the same port that PushEx runs, such as a health check.

Here is an example of how to do this:

```elixir
# config.exs

additional_setup = quote do
  use Plugsnag
end

config :push_ex, PushExWeb.Router,
  additional_setup: additional_setup
```

You can see that the additional setup uses a quoted block in order to include the custom code. This code will then be injected into the PushExWeb.Router at compile time.

Due to this needing to happen at compile time, you must use a quoted block and not a module in your application's lib. Your app is compiled after all dependencies, but PushEx dependency would need access to a module in your app. This would cause an incorrect ordering and you would encounter a module not defined error. This also means that you would not be able to `use MyApp.CustomPlug` because `MyApp` isn't available during PushEx compilation.
