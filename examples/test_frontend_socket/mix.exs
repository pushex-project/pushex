defmodule TestFrontendSocket.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_frontend_socket,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TestFrontendSocket.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:push_ex, ">= 0.0.0", path: "../.."},
      {:phoenix_pubsub_redis, "~> 3.0"},
      {:benchee, "~> 0.11", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
