defmodule GENSERVERS do
  use GenServer

  def start_link(num) do
    publicKey = "sjkbf"
    privateKey = "skjN"
    hashValue = :crypto.hash(:sha, "Node_" <> Integer.to_string(num)) |> Base.encode16
    GenServer.start_link(__MODULE__,[publicKey,privateKey], name: String.to_atom("h_" <> hashValue))
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end
end
