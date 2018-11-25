defmodule MAIN do
  require MINERSERVER
  :ets.new(:table, [:bag, :named_table,:public])
  SSUPERVISOR.start_link(100)
  IO.puts "Nodes started"
  Enum.each(1..5, fn x-> MINERSERVER.start_link end)
  IO.puts "Miners started"
  IO.puts "Creating genesis block"
  firstBlock = BLOCKCHAIN.createGenesisBlock()
  :ets.insert(:table,{"Blocks",1,firstBlock})
  IO.puts "printing final block"
  IO.inspect :ets.lookup(:table,"unspentTxns")
  #TRANSACTION.transactionChain(2)
  #Process.sleep(200)
  #TASKFINDER.run()

end

