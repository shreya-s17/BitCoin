defmodule MAIN do
  require MINERSERVER

  :ets.new(:table, [:bag, :named_table,:public])
  SSUPERVISOR.start_link(10)
  IO.puts "Nodes started"
  Enum.each(1..5, fn x-> MINERSERVER.start_link end)
  IO.puts "Miners started"
  IO.puts "Creating genesis block"
  nbits = BLOCKCHAIN.calculateNBits()
  firstBlock = BLOCKCHAIN.createGenesisBlock(nbits)
  :ets.insert(:table,{"Blocks",1,firstBlock})
  IO.puts "printing final block"
  TRANSACTION.transactionChain(10)
  Process.sleep(200)
  TASKFINDER.run(2, nbits)

end

