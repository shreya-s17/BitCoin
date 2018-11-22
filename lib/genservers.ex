defmodule GENSERVERS do
  use GenServer

  def start_link() do
    [privateKey, publicKey] = KEYGENERATION.generate()
    GenServer.start_link(GENSERVERS,[privateKey, publicKey], name: String.to_atom("h_" <> publicKey))
    publicKey = KEYGENERATION.to_public_hash(privateKey)
    :ets.insert(:table, {"publicKeys", publicKey})
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_call({:getState}, _from, state) do
    {:reply, state, state}
  end
end
