defmodule PushEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :push_ex,
      version: "0.0.1-rc3",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "TODO",
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
      licenses: ["TODO"],
      links: %{github: "https://www.github.com/SalesLoft/push.ex"},
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
      extras: [
        "guides/installation/standalone.md",
      ],
      groups_for_extras: [
        "Installation": Path.wildcard("guides/installation/*.md")
      ],
    ]
  end
end
