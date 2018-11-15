defmodule SocketServer.Writer.StdOut do
  def write(vals) when is_list(vals) do
    IO.puts(Enum.join(vals, ", "))
  end
end
