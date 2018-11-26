defmodule MINERSERVER do
  use GenServer
  @miningValue 25

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

  def handle_call({:validateBlock, block, no}) do
      [hash, map, count, tList] = block
      list = :ets.lookup(:table,"Blocks")
      #verifyEntireChain(block)
      result = if(validateBlockChain(Map.get(map,:previousBlockHash), no, 0, list) && BLOCKCHAIN.validateHash(block)
       && validateTransaction(tList) && validateMerkleRoot(Map.get(map,:merkleRoot), tList)) do
                      true
                  else
                      false
                  end
      {:reply, result}
  end

  def validateBlockChain(phash, no, pno,list) do
      if(pno==0) do
          true
      else
          {_,pno1,[phash1,map,_,_]} = Enum.at(list,pno-1)
          if(phash1 ==phash && no ==pno1-1) do
              validateBlockChain(Map.get(map,:previousBlockHash), pno1, pno1-1, list)
          else
              false
          end
      end
  end

  def validateMerkleRoot(merkleRoot, list) do
      if(BLOCKCHAIN.calculateMerkleRoot(list,0) == merkleRoot) do
          true
      else
          false
      end

  end

  def validateTransaction(tList) do
      #if(Enum.count(tList) == 0) do
      #    false
      #else

          #newList = Enum.slice(1..Enum.count(tList))
          #boo = Enum.all?(newList, fn {hash, tfee, map} ->
          #end)
          #fee = Enum.map(newList, fn {_, tfee, _} ->
           #   tfee
          #end)
          #{_,_,map} = Enum.at(tList,0)
          #if(boo == true && @miningValue + Enum.sum(fee) >= Map.get(map,3)) do
          #    true
          #else
           #   false
          #end
      ## only 1st coinbase
      # list = :ets.lookup(:blocks,"unspentTrans")
       #if(Enum.count(list)>0
      # && !Enum.any?(list, fn {id,_}-> id==transid end)
       #&& Enum.count(tList, fn {id,_}-> id==transid end) ==1) do

       #else
       #    :false

       #end

      #end
      true
   end



end
