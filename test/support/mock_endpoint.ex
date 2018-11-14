defmodule PushEx.Test.MockEndpoint do
  require Logger

  def broadcast!(ch, msg, item) do
    Logger.debug "MockEndpoint broadcast!/3 #{inspect({ch, msg, item})}"
  end
end
