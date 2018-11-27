defmodule MAIN do
    require MINERSERVER

    :ets.new(:table, [:bag, :named_table,:public])

    SSUPERVISOR.start_link(20)
    Enum.each(1..3, fn x-> MINERSERVER.start_link end)
    nbits = BLOCKCHAIN.calculateNBits()
    firstBlock = BLOCKCHAIN.createGenesisBlock(nbits)
    :ets.insert(:table,{"Blocks",1,firstBlock})
    transferAmt = Enum.random(1..24)
    TRANSACTION.transactionChain(2,transferAmt)
    Process.sleep(200)
    TASKFINDER.run(20, nbits, 0)
    IO.inspect(:ets.lookup(:table,"unspentTxns"))
    #IO.inspect(:ets.lookup(:table,"pendingTxns"))
    #IO.inspect(:ets.lookup(:table,"Blocks"))
  end
