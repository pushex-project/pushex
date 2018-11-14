defmodule PushEx.ConfigTest do
  use ExUnit.Case, async: false

  alias PushEx.Config

  describe "socket_impl/0" do
    test "returns the correct impl" do
      Application.put_env(:push_ex, PushExWeb.PushSocket, socket_impl: "test")
      assert Config.socket_impl() == "test"
    end
  end

  describe "controller_impl/0" do
    test "returns the correct impl" do
      Application.put_env(:push_ex, PushExWeb.PushController, controller_impl: "test")
      assert Config.controller_impl() == "test"
    end
  end

  describe "producer_max_buffer/0" do
    test "defaults to 50_000" do
      Application.delete_env(:push_ex, PushExWeb.PushSocket)
      assert Config.producer_max_buffer() == 50_000
    end

    test "a value can be provided" do
      Application.put_env(:push_ex, PushExWeb.PushSocket, producer_max_buffer: 10_000)
      assert Config.producer_max_buffer() == 10_000
    end
  end

  describe "producer_max_concurrency/0" do
    test "defaults to 10" do
      Application.delete_env(:push_ex, PushExWeb.PushSocket)
      assert Config.producer_max_concurrency() == 10
    end

    test "a value can be provided" do
      Application.put_env(:push_ex, PushExWeb.PushSocket, producer_max_concurrency: 5)
      assert Config.producer_max_concurrency() == 5
    end
  end

  describe "endpoint/0" do
    test "defaults to PushExWeb.Endpoint" do
      Application.delete_env(:push_ex, PushExWeb.PushSocket)
      assert Config.endpoint() == PushExWeb.Endpoint
    end

    test "a value can be provided" do
      Application.put_env(:push_ex, PushExWeb.PushSocket, endpoint: :test)
      assert Config.endpoint() == :test
    end
  end

  describe "push_listeners/0" do
    test "defaults to []" do
      Application.delete_env(:push_ex, PushEx.Instrumentation)
      assert Config.push_listeners() == []
    end

    test "a value can be provided" do
      Application.put_env(:push_ex, PushEx.Instrumentation, push_listeners: [:a])
      assert Config.push_listeners() == [:a]
    end
  end

  describe "check!/0" do
    test "errors without a socket_impl" do
      Application.put_env(:push_ex, PushExWeb.PushSocket, socket_impl: nil)
      Application.put_env(:push_ex, PushExWeb.PushController, controller_impl: "test")

      assert_raise(RuntimeError, "config :push_ex, PushExWeb.PushSocket, socket_impl: ModName must be set", fn ->
        Config.check!()
      end)
    end

    test "errors without a controller_impl" do
      Application.put_env(:push_ex, PushExWeb.PushSocket, socket_impl: "test")
      Application.put_env(:push_ex, PushExWeb.PushController, controller_impl: nil)

      assert_raise(RuntimeError, "config :push_ex, PushExWeb.PushController, controller_impl: ModName must be set", fn ->
        Config.check!()
      end)
    end

    test "no errors normally" do
      Application.put_env(:push_ex, PushExWeb.PushSocket, socket_impl: "test")
      Application.put_env(:push_ex, PushExWeb.PushController, controller_impl: "test")
      Config.check!()
    end
  end
end
