defmodule PushExWeb.Router do
  @moduledoc false

  use PushExWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  if PushExWeb.RouterLoader.external_resource() do
    use PushExWeb.RouterLoader
    @external_resource PushExWeb.RouterLoader.external_resource()
  end

  scope "/api", PushExWeb do
    pipe_through :api

    post "/push", PushController, :create
  end
end
