defmodule PushEx.Test.MockController do
  def setup_config(:logging) do
    Application.put_env(:push_ex, PushExWeb.PushController, controller_impl: PushEx.Test.MockController.LoggingController)
  end

  def setup_config(:error) do
    Application.put_env(:push_ex, PushExWeb.PushController, controller_impl: PushEx.Test.MockController.ErrorController)
  end

  def setup_config(:specific_error) do
    Application.put_env(:push_ex, PushExWeb.PushController, controller_impl: PushEx.Test.MockController.SpecificErrorController)
  end

  def setup_config(:specific_ok) do
    Application.put_env(:push_ex, PushExWeb.PushController, controller_impl: PushEx.Test.MockController.SpecificOkController)
  end

  defmodule LoggingController do
    @behaviour PushEx.Behaviour.Controller
    require Logger

    def auth(_conn, params) do
      Logger.debug("LoggingController auth/2 #{inspect({"conn", params})}")
      :ok
    end
  end

  defmodule ErrorController do
    @behaviour PushEx.Behaviour.Controller

    def auth(_conn, _params) do
      :error
    end
  end

  defmodule SpecificErrorController do
    @behaviour PushEx.Behaviour.Controller

    def auth(conn, _params) do
      {:error, Plug.Conn.send_resp(conn, 400, "resp")}
    end
  end

  defmodule SpecificOkController do
    @behaviour PushEx.Behaviour.Controller

    def auth(conn, params) do
      {:ok, Plug.Conn.put_status(conn, 202), Map.put(params, "channel", "modified")}
    end
  end
end
