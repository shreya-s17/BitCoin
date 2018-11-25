defmodule GENSERVERS do
  use GenServer

  def start_link(args) do
    [privateKey, publicKey] = KEYGENERATION.generate()
    :ets.insert(:table, {"PublicKeys", KEYGENERATION.to_public_hash(privateKey)})
    GenServer.start_link(__MODULE__,[privateKey,publicKey,2],
        name: String.to_atom("h_" <> publicKey))
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_cast({:updateWallet, amount}, state) do
    [private, public, unspent, currentBlk] = state
    state = [private, public, unspent + amount, currentBlk]
    {:noreply, state}
  end

  def handle_call({:getState}, _from, state) do
    {:reply, state, state}
  end
end
