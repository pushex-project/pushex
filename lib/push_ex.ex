defmodule PushEx do
  @moduledoc """
  PushEx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias PushEx.Push
  alias Push.ItemProducer

  def push(item = %Push{}) do
    ItemProducer.push(item)
  end

  def unix_now(), do: (:erlang.system_time() / 1_000_000) |> round()
end
