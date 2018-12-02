defmodule PushExWeb.RouterLoader do
  @moduledoc false

  @doc """
  Loads an AST from config to be used in the Router. This must be an AST because the
  order of compilation prevents using a module directly (without some sort of hack to change
  compilation ordering).
  """
  defmacro __using__([]) do
    with router_config <- Application.get_env(:push_ex, PushExWeb.Router, []),
         ast <- Keyword.get(router_config, :additional_setup) do
      ast
    end
  end
end
