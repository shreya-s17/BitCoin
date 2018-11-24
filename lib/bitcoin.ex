defmodule BITCOIN do
  #CoinBase - 1st transaction per block
  #no inputs only outputs

  #block chain-
  #timestamping or ordering of transactions to prevent double spending
  def mineBitCoin() do
    #ets.insert(:table, {"pendingTxns", {rawTransactionOut,
    #[input_txids, publicKeyHash, outPubKey, amount]}})

    #GenServer.cast(String.to_atom("m_1") ,{:pred,Enum.at(nodeList, numNodes-1)})
  end

  def countList(i,count) do
    if(:math.pow(2,i) > count) do
      i-1
    else
      countList(i+1,count)
    end
  end

  def startMining(no) do
    Process.sleep(500)
    list = :ets.lookup(:table, "pendingTxns")
    count = Enum.count(list)
    pow = :math.pow(2,countList(0,count))
    count = if(pow==count || pow+1==count)do
              count
            else
              pow+1
            end
    GenServer.cast(String.to_atom("m_1"), {:mineBlock, count, list, no})
    startMining(no+1)
  end

  def main() do
    count = 0
    :ets.new(:table, [:bag,:named_table,:protected])
    #GenServer.start_link(CHORD,[hashValue,%{},[],""], name: String.to_atom("h_" <> hashValue))
    #GenServer.start_link(STABILIZEGENSERVER,[], name: :stabilize)
    firstBlock = BLOCKCHAIN.createGenesisBlock()
    :ets.insert(:table,{"Blocks",Integer.to_string(count+1),firstBlock,0,[]})
    spawn(fn -> startMining(2) end)
    # {rawTransactionOut,[input_txids, publicKeyHash, outPubKey, amount]}})
    IO.inspect(firstBlock)
    list = Enum.map(1..3,fn x->
        :crypto.hash(:sha256,:crypto.hash(:sha256,BLOCKCHAIN.randomString(3))) |> Base.encode16
    end)

end

end
