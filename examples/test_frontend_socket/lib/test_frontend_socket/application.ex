defmodule TestFrontendSocket.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      PushEx.Supervisor,
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: {Plug.Static, [at: "/", from: "assets"]},
        options: [port: one_port_down()]
      )
    ]

    opts = [strategy: :one_for_one, name: TestFrontendSocket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def one_port_down() do
    Application.get_env(:push_ex, PushExWeb.Endpoint)
    |> Keyword.get(:http)
    |> Keyword.get(:port)
    |> Kernel.-(1)
  end
end
