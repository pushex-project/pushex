defmodule PushExWeb.ConfigTest do
  use ExUnit.Case, async: false

  alias PushExWeb.Config

  describe "close_connections?/0" do
    test "it is false by default" do
      # Test flakes without restarting the config server
      Process.exit(Process.whereis(Config), :kill)
      Process.sleep(100)
      assert Config.close_connections?() == false
    end

    test "it can be set to true or false" do
      Config.close_connections!(true)
      assert Config.close_connections?() == true

      Config.close_connections!(false)
      assert Config.close_connections?() == false
    end
  end
end
