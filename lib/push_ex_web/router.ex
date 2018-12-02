defmodule PushExWeb.Router do
  @moduledoc false

  use PushExWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  use PushExWeb.RouterLoader

  scope "/api", PushExWeb do
    pipe_through :api

    post "/push", PushController, :create
  end
end
