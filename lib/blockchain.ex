defmodule BLOCKCHAIN do

  @difficulty_target "00805F511E5157EB90B7754ACC85055B19EA74B43BD0F1D7A066946F973F87E8"
  @miningValue 25
  def calculateMerkleRoot(list,i) do
      count = Enum.count(list)
      if(count == 1) do
          Enum.at(list,0)
      else
          first = Enum.at(list,i)
          list = List.delete_at(list,i)
          {second,list} =if(i+1>=count) do
                      {first,list}
                  else
                      s=Enum.at(list,i)
                      list = List.delete_at(list,i)
                      {s,list}
                  end
          list = List.insert_at(list,i,:crypto.hash(:sha256,:crypto.hash(:sha256,first<>second)) |> Base.encode16)
          if(i+1>=Enum.count(list)) do
              calculateMerkleRoot(list,0)
          else
              calculateMerkleRoot(list,i+1)
          end
      end
  end

  def getLatestBlock() do
      list=:ets.lookup(:table,"Blocks")
      {_,hash,_,_} = Enum.at(list,-1)
      hash
  end

  def find6digits(number,i) do
      if(String.at(number,i)=="0") do
          find6digits(number,i+1)
      else
          i
      end
  end

  def calculateNBits() do
      number = @difficulty_target
      digit = find6digits(number,0)
      length = String.length(number)
      result = if(digit==0 && String.slice(number,0..1)>"7F") do
                  Integer.to_string(div(length+2,2),16) <> "00" <> String.slice(number,0..3)
              else
                  digit = if(rem(digit,2) != 0) do
                              digit-1
                          else
                              digit
                          end
                  Integer.to_string(div(length-digit,2),16) <> String.slice(number,digit..digit+5)
              end
      result
  end

  def createCoinBase(transactionFees) do
    keys = :ets.lookup(:table,"PublicKeys")
    list = Enum.map(keys, fn {_,x}->
              TRANSACTION.coinBase(x, transactionFees)
            end)
    list
  end

  def createBlockHeader(miner, transactionList, transactionFees, minerFee, previousBlock) do
      #change here nultiple coinbase trans for genesis block
      transList = if(miner == NULL) do
                      createCoinBase(transactionFees)
                  else
                      [TRANSACTION.coinBase(miner,transactionFees+minerFee)| transactionList]
                  end
      count = Enum.count(transList)
      newList = Enum.map(transList, fn {_,x,_,_} -> x end)
      newTransList = Enum.map(transList, fn x-> Tuple.delete_at(x,0) end)
      merkleRoot = calculateMerkleRoot(newList,0)
      version =<<1::32>>
      time =  <<System.system_time(:second)::32>>
      nbits = calculateNBits()
      [calculateNonce(merkleRoot,version,previousBlock,time,nbits,0),previousBlock, count, newTransList]
  end

  def calculateNonce(merkleRoot,version,previousBlock,time,nbits,nonce) do
      hashBlock = :crypto.hash(:sha256,version <> previousBlock <> merkleRoot <> time <> nbits <> <<nonce::32>>) |> Base.encode16
      if(String.slice(hashBlock,0..1) != "00" || String.at(hashBlock,2) =="0" || hashBlock > @difficulty_target) do
          calculateNonce(merkleRoot,version,previousBlock,time,nbits,nonce+1)
      else
          hashBlock
      end
  end

  def createGenesisBlock() do
      block = createBlockHeader(NULL, [], @miningValue, 0, "0000000000000000000000000000000000000000000000000000000000000000")
      Enum.each(Enum.at(block,3), fn x -> :ets.insert(:table, {"unspentTxns", x}) end)
      block
  end

  def validateTransaction(tList) do
     # list = :ets.lookup(:blocks,"unspentTrans")
      #if(Enum.count(list)>0
     # && !Enum.any?(list, fn {id,_}-> id==transid end)
      #&& Enum.count(tList, fn {id,_}-> id==transid end) ==1) do

      #else
      #    :false
      #end
      :true
  end

  def temp do
      :ets.new(:blocks, [:bag,:named_table,:protected])
      :ets.insert(:blocks,{"blocs",1,9})
      :ets.insert(:blocks,{"blocs",2})
      :ets.insert(:blocks,{"blocs",3})
      :ets.insert(:blocks,{"hh",3})
      IO.inspect :ets.lookup(:blocks,"blocs")
      :ets.delete(:blocks, "blocs")
      IO.inspect :ets.lookup(:blocks,"blocs")
      :ets.insert(:blocks,{"blocs",1,9})
      IO.inspect :ets.lookup(:blocks,"blocs")
  end
end
