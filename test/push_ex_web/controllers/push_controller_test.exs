defmodule PushExWeb.PushControllerTest do
  use PushExWeb.ConnCase, async: false

  import ExUnit.CaptureLog

  test "a single channel can be pushed to", %{conn: conn, test: channel} do
    PushEx.Test.MockController.setup_config(:logging)
    PushEx.Test.MockInstrumenter.setup_config()
    channel = to_string(channel)
    params = %{"channel" => channel, "data" => "d", "event" => "e"}

    log =
      capture_log(fn ->
        assert conn
               |> post("/api/push", params)
               |> json_response(200) == %{"channel" => [channel], "data" => "d", "event" => "e"}
      end)

    assert PushEx.Test.MockInstrumenter.state() == %{
             api_processed: [[]],
             api_requested: [[]],
             delivered: [],
             requested: [[%PushEx.Push{channel: channel, data: "d", event: "e"}]]
           }

    assert log =~ "LoggingController auth/2 " <> inspect({"conn", params})
    assert log =~ "Push.ItemServer no_listeners channel=#{channel}"
  end

  test "multiple channels can be pushed to", %{conn: conn, test: channel} do
    PushEx.Test.MockController.setup_config(:logging)
    PushEx.Test.MockInstrumenter.setup_config()
    channels = [to_string(channel), to_string(channel) <> "2"]
    params = %{"channel" => channels, "data" => "d", "event" => "e"}

    log =
      capture_log(fn ->
        assert conn
               |> post("/api/push", params)
               |> json_response(200) == %{"channel" => channels, "data" => "d", "event" => "e"}
      end)

    assert PushEx.Test.MockInstrumenter.state() == %{
             api_processed: [[]],
             api_requested: [[]],
             delivered: [],
             requested: [
               [%PushEx.Push{channel: Enum.at(channels, 1), data: "d", event: "e"}],
               [%PushEx.Push{channel: Enum.at(channels, 0), data: "d", event: "e"}]
             ]
           }

    assert log =~ "LoggingController auth/2 " <> inspect({"conn", params})
    assert log =~ "Push.ItemServer no_listeners channel=#{Enum.at(channels, 0)}"
    assert log =~ "Push.ItemServer no_listeners channel=#{Enum.at(channels, 1)}"
  end

  ["channel", "data", "event"]
  |> Enum.map(fn field ->
    test "#{field} is a required param", %{conn: conn, test: channel} do
      PushEx.Test.MockController.setup_config(:logging)
      params = Map.delete(%{"channel" => channel, "data" => "d", "event" => "e"}, unquote(field))

      log =
        capture_log(fn ->
          assert conn
                 |> post("/api/push", params)
                 |> json_response(422) == %{"error" => "Invalid push arguments: channel, data, event are required."}
        end)

      refute log =~ "Push.ItemServer"
    end
  end)

  describe "with_auth" do
    test ":error returns a 403", %{conn: conn, test: channel} do
      PushEx.Test.MockController.setup_config(:error)
      params = %{"channel" => channel, "data" => "d", "event" => "e"}

      log =
        capture_log(fn ->
          assert conn
                 |> post("/api/push", params)
                 |> json_response(403) == %{"error" => "Access forbidden"}
        end)

      refute log =~ "Push.ItemServer"
    end

    test "{:error, conn} returns the conn directly", %{conn: conn, test: channel} do
      PushEx.Test.MockController.setup_config(:specific_error)
      params = %{"channel" => channel, "data" => "d", "event" => "e"}

      log =
        capture_log(fn ->
          assert conn
                 |> post("/api/push", params)
                 |> response(400) == "resp"
        end)

      refute log =~ "Push.ItemServer"
    end

    test "{:ok, conn, params} calls with the modified params/conn", %{conn: conn, test: channel} do
      PushEx.Test.MockController.setup_config(:specific_ok)
      params = %{"channel" => channel, "data" => "d", "event" => "e"}

      log =
        capture_log(fn ->
          assert conn
                 |> post("/api/push", params)
                 |> json_response(202) == %{"channel" => ["modified"], "data" => "d", "event" => "e"}
        end)

      assert log =~ "Push.ItemServer no_listeners channel=modified event=e"
    end
  end
end
