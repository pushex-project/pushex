defmodule PushEx.Test.MockItemServer do
  def setup() do
    {:ok, agent} = Agent.start_link(fn -> [] end)
    agent
  end

  def start_link(
        arg = %{
          item: %PushEx.Push{data: agent_pid},
          at: _
        }
      ) do
    Task.start_link(fn ->
      # Maintain async by passing in the agent_pid through the item
      Agent.update(agent_pid, fn calls -> [[arg] | calls] end)
    end)
  end
end
