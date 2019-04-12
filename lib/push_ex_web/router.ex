defmodule PushExWeb.Router do
  @moduledoc false

  use PushExWeb, :router

  if PushExWeb.RouterLoader.external_resource() do
    use PushExWeb.RouterLoader
    @external_resource PushExWeb.RouterLoader.external_resource()
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PushExWeb do
    pipe_through :api

    post "/push", PushController, :create
  end
end
