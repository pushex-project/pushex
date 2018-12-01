defmodule PushExWeb.RouterLoader do
  defmacro __using__([]) do
    with router_config <- Application.get_env(:push_ex, PushExWeb.Router, []),
         ast <- Keyword.get(router_config, :additional_plug_setup) do
      ast
    end
  end
end
