defmodule PushExWeb.Router do
  use PushExWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PushExWeb do
    pipe_through :api
  end
end
