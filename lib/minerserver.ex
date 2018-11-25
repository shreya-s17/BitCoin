defmodule MINERSERVER do
  use GenServer

  def start_link do
    [privateKey, publicKey] = KEYGENERATION.generate()
    :ets.insert(:table, {"MinerPublicKeys", KEYGENERATION.to_public_hash(privateKey)})
    GenServer.start_link(__MODULE__,[privateKey,publicKey,0],
        name: String.to_atom("m_" <> publicKey))
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_call({:validateBlock, block}) do
      {hash,no,tList} = block
      #verifyEntireChain(block)
      #if(BLOCKCHAIN.validateTransaction(tList) &&   BLOCKCHAIN.calculateMerkleRoot()) do
    #end
    {:reply, true}
  end
end
