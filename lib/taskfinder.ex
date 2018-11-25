defmodule TASKFINDER do
  use Task
  require MINERSERVER

  @miningValue 25

def run(no) do
  list = :ets.lookup(:table, "pendingTxns")
  tempList = Enum.sort(list, &(Kernel.elem(&1,2) <= Kernel.elem(&2,2)))
  nlist = Enum.filter(tempList, fn x -> BLOCKCHAIN.validateTransaction(x)==true end)
  count = Enum.count(nlist)
  pow = :math.pow(2,countList(0,count))
  count = if(pow==count || pow+1==count) do
            count
          else
            pow+1
          end
  list = Enum.slice(nlist,0..count)
  minerFee = Enum.reduce(list, fn {_,_,x,_}, acc-> acc+x end)
  miners = :ets.lookup(:table,"MinerPublicKeys")
  tasksList = Enum.each(miners, fn {_,x}->
    Task.async(fn -> startMining(list, "m_" <> x, minerFee) end)
  end)
  await(tasksList,no)
  Process.sleep(500)
  run(no+1)
end

def await(tasks,no) do
  receive do
    message ->
      case Task.find(tasks, message) do
        {:fail, task} ->
          await(List.delete(tasks, task),no)
        {block, task} ->
          IO.inspect block
          Enum.each(List.delete(tasks, task),fn x -> Task.shutdown(x,:normal) end)
          val = Enum.all?(1..5, fn x ->
            {_,reply} = GenServer.call(String.to_atom("m_"<>x), {:validateBlock, block})
            reply == :true end)
          if(val) do
            :ets.insert(:table,{"Blocks",[no,block]})
            insertUnspentTxns(Enum.at(block,3))
          else
            run(no)
          end
        nil ->
          await(tasks,no)
      end
  end
end

def startMining(nList,miner, minerFee) do
  if(Enum.count(nList)>0) do
    BLOCKCHAIN.createBlockHeader(miner, nList, @miningValue, minerFee, BLOCKCHAIN.getLatestBlock())
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
  tList = Enum.filter(tList, fn x-> !Enum.member?(list, x) end)
  :ets.delete(:table,"pendingTxns")
  Enum.each(tList, fn x-> :ets.insert(:table,{"pendingTxns", x}) end)
  Enum.each(list, fn x-> :ets.insert(:table,{"unspentTxns", x}) end)
end

end
