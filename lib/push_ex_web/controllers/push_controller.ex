defmodule PushExWeb.PushController do
  use PushExWeb, :controller

  def create(conn, params) do
    PushEx.Instrumentation.Push.api_requested()

    with_auth(conn, params, fn conn, params ->
      with_params_validation(conn, params, fn conn, %{"channel" => channel, "data" => data, "event" => event} ->
        wrapped_channel = List.wrap(channel)

        wrapped_channel
        |> Enum.each(fn channel ->
          %PushEx.Push{channel: channel, data: data, event: event}
          |> PushEx.push()
        end)

        PushEx.Instrumentation.Push.api_processed()

        conn
        |> json(%{channel: wrapped_channel, data: data, event: event})
      end)
    end)
  end

  defp with_params_validation(conn, params = %{"channel" => channel, "data" => _, "event" => event}, func)
       when (is_bitstring(channel) or is_list(channel)) and is_bitstring(event) do
    func.(conn, params)
  end

  defp with_params_validation(conn, _, _) do
    conn
    |> put_status(422)
    |> json(%{error: "Invalid push arguments: channel, data, event are required."})
  end

  defp with_auth(conn, params, func) do
    case PushEx.Config.controller_impl().auth(conn, params) do
      :ok ->
        func.(conn, params)

      {:ok, conn = %Plug.Conn{}, params = %{}} ->
        func.(conn, params)

      {:error, conn = %Plug.Conn{}} ->
        conn

      :error ->
        conn
        |> put_status(403)
        |> json(%{error: "Access forbidden"})
    end
  end
end
