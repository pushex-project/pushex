defmodule SocketServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {SocketServer.StatsLogger, [tick: 1_000]}
    ]

    opts = [strategy: :one_for_one, name: SocketServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
