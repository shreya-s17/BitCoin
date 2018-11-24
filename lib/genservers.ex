defmodule GENSERVERS do
  use GenServer

  def start_link(args) do
    [privateKey, publicKey] = KEYGENERATION.generate()
    :ets.insert(:table, {"PublicKeys", {KEYGENERATION.to_public_hash(privateKey)}})
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

  def handle_cast({:mineBlock, count, list, no}, state) do
    #[hash,_,list,pred] = state
    #state = [hash,val,list,pred]

    list = :ets.lookup(:table, "pendingTxns")
    #length = Enum.count(list)
    #pow = :math.pow(2,countList(0,count))
    #nlist = Enum.filter(list, fn x-> BLOCKCHAIN.validateTransactions(x,"xv")==true end)
    list = Enum.slice(list,0..count)
    if(Enum.count(list)>0) do
      blockHash = BLOCKCHAIN.createBlockHeader(list,@miningValue,BLOCKCHAIN.getLatestBlock(4))
      :ets.insert(:table,{"Blocks",no,blockHash,Enum.count(list),list})
      #:ets.insert(:table,{Integer.to_string(count+2),blockHash})
    end
    {:noreply ,state}
  end

  def countList(i,count) do
    if(:math.pow(2,i) > count) do
      i-1
    else
      countList(i+1,count)
    end
  end

end
