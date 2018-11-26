defmodule TASKFINDER do
  use Task
  require MINERSERVER

  @miningValue 25

def run(no,nbits) do
  list = :ets.lookup(:table, "pendingTxns")
  tempList = Enum.sort(list, &(Kernel.elem(&1,2) <= Kernel.elem(&2,2)))
  nlist = Enum.filter(tempList, fn x -> MINERSERVER.validateTransaction(x)==true end)
  count = Enum.count(nlist)
  pow = :math.pow(2,countList(0,count))
  count = if(pow==count || pow+1==count) do
            count
          else
            pow+1
          end
  list = Enum.slice(nlist,0..round(count))

  minerFee = Enum.reduce(list,0, fn {_,_,x,_}, acc-> acc+x end)
  miners = :ets.lookup(:table,"MinerPublicKeys")
  tasksList = Enum.each(miners, fn {_,x}->
    Task.async(fn -> startMining(list, "m_" <> x, minerFee,nbits) end)
  end)
  await(tasksList,no,nbits)
  #Process.sleep(500)
  #run(no+1)
end

def await(tasks,no,nbits) do
  receive do
    message ->
      IO.puts "hey"
      IO.inspect message
      IO.inspect tasks
      case Task.find(tasks, message) do
        {:fail, task} ->
          await(List.delete(tasks, task),no,nbits)
        {block, task} ->
          Enum.each(List.delete(tasks, task),fn x -> Task.shutdown(x,:normal) end)
          miners = :ets.lookup(:table,"MinerPublicKeys")
          val = Enum.all?(miners, fn {_,x} ->
            {_,reply} = GenServer.call(String.to_atom("m_"<>x), {:validateBlock, block, no})
            reply == :true end)
          if(val) do
            :ets.insert(:table,{"Blocks",no,block})
            insertUnspentTxns(Enum.at(block,3))
          else
            run(no,nbits)
          end
        nil ->
          await(tasks,no,nbits)
      end
  end
end

def startMining(nList,miner, minerFee,nbits) do
  if(Enum.count(nList)>0) do
    BLOCKCHAIN.createBlockHeader(miner, nList, @miningValue, minerFee, BLOCKCHAIN.getLatestBlock(),nbits)
  else
    :fail
  end
end

def countList(i,count) do
  if(:math.pow(2,i) > count) do
    i-1
  else
    countList(i+1,count)
  end
end

def insertUnspentTxns(list) do
  tList = :ets.lookup(:table,"pendingTxns")
  tList = Enum.filter(tList, fn {_,x,y,z}-> !Enum.member?(list, {x,y,z}) end)
  :ets.delete(:table,"pendingTxns")
  Enum.each(tList, fn {_,x,y,z}-> :ets.insert(:table,{"pendingTxns", x,y,z}) end)
  Enum.each(list, fn {_,x,y,z}-> :ets.insert(:table,{"unspentTxns", x,y,z}) end)
end

end
