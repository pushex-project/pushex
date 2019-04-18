defmodule PushEx.MixProject do
  use Mix.Project

  @version "1.0.0-rc9"

  def project do
    [
      app: :push_ex,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "PushEx",
      description:
        "PushEx is an implementation of Phoenix websockets/channels which handles best practices of running websockets for you, but allows your business logic to be specified through simple behaviour modules.",
      package: package(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PushEx.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp package() do
    [
      maintainers: [
        "Steve Bussey"
      ],
      licenses: ["MIT"],
      links: %{github: "https://github.com/pushex-project/pushex"},
      files: ~w(lib) ++ ~w(mix.exs README.md)
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:gen_stage, "~> 0.14"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs() do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extra_section: "GUIDES",
      extras: [
        "README.md",
        "guides/installation/standalone.md",
        "guides/usage/authentication.md",
        "guides/usage/custom_plugs.md",
        "guides/usage/deployment.md",
        "guides/usage/instrumentation.md",
        "guides/usage/js.md",
        "guides/usage/pub_sub.md",
        "guides/usage/push_api.md"
      ],
      groups_for_extras: [
        Installation: Path.wildcard("guides/installation/*.md"),
        Usage: Path.wildcard("guides/usage/*.md")
      ],
      groups_for_modules: [
        Behaviours: [
          PushEx.Behaviour.Controller,
          PushEx.Behaviour.PushInstrumentation,
          PushEx.Behaviour.Socket
        ],
        "Data Types": [
          PushEx.Push,
          PushEx.Instrumentation.Push.Context
        ],
        Misc: [
          PushExWeb.Router.Helpers
        ]
      ]
    ]
  end
end
