defmodule BLOCKCHAIN do

  @difficulty_target "8C05F511E5157EB90B77545ACC85055B19EA74B43BD0F1D7A066946F973F87E8"
  @miningValue "12.5"
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

  def getLatestBlock(count) do
      [{_,prev}]=:ets.lookup(:table,Integer.to_string(count-1))
      prev
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
      IO.puts("a #{inspect digit} #{inspect length}")
      result = if(digit==0 && String.slice(number,0..1)>"7F") do
                  Integer.to_string(div(length+2,2),16) <> "00" <> String.slice(number,0..3)
              else
                  digit = if(rem(digit,2) != 0) do
                              digit-1
                          else
                              digit
                          end
                          IO.inspect div(length-digit,2)
                  Integer.to_string(div(length-digit,2),16) <> String.slice(number,digit..digit+5)
              end
      result
  end

  def createCoinbaseTransaction(fees) do
      IO.puts "hi"
      :crypto.hash(:sha256,:crypto.hash(:sha256,fees)) |> Base.encode16
  end

  def createBlockHeader(transactionList,transactionFees,previousBlock) do
      newList = [createCoinbaseTransaction(transactionFees)| transactionList]
      IO.puts "here"
      merkleRoot =
      if(Enum.count(newList)==1) do
          Enum.at(newList,0)
      else
          calculateMerkleRoot(newList,0)
      end
      IO.inspect merkleRoot
      version =<<1::32>>
      time =  <<System.system_time(:second)::32>>
      nbits = calculateNBits()
      calculateNonce(merkleRoot,version,previousBlock,time,nbits,0)
  end

  def calculateNonce(merkleRoot,version,previousBlock,time,nbits,nonce) do
      hashBlock = :crypto.hash(:sha256,version <> previousBlock <> merkleRoot <> time <> nbits <> <<nonce::32>>) |> Base.encode16
      if(String.slice(hashBlock,0..1) != "00" || String.at(hashBlock,2) =="0" || hashBlock > @difficulty_target) do
          #IO.inspect nonce
          #IO.inspect hashBlock
          calculateNonce(merkleRoot,version,previousBlock,time,nbits,nonce+1)
      else
          hashBlock
      end
  end

  def createGenesisBlock() do
      createBlockHeader([],@miningValue,"0x0000000000000000000000000000000000000000000000000000000000000000")
  end

  def validateBlock() do

  end

  def validateTransaction(transid,tList) do
      list = :ets.lookup(:blocks,"unspentTrans")
      if(Enum.count(list)>0
      && !Enum.any?(list, fn {id,_}-> id==transid end)
      && Enum.count(tList, fn {id,_}-> id==transid end) ==1) do

      else
          :false
      end
  end

  def randomString(length) do
      charList = Enum.map(1..length, fn x ->
        Enum.random(['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'])
      end)
      List.to_string(charList)
  end

end
