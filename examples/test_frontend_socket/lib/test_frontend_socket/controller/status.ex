defmodule TestFrontendSocket.Controller.Status do
  use PushExWeb, :controller

  def show(conn, _params) do
    conn
    |> resp(200, "OK")
  end
end
