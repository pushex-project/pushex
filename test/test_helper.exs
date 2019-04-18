PushEx.Test.MockInstrumenter.setup()
{:ok, _pid} = Supervisor.start_link([PushEx], strategy: :one_for_one)
ExUnit.start()
