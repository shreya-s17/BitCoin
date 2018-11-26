defmodule BITCOINTest do
  use ExUnit.Case

  # unit test cases
  test "Create genesis block with initial amount" do
    :ets.new(:table, [:bag, :named_table,:public])
    numNodes = 10;
    SSUPERVISOR.start_link(numNodes)
    firstBlock = BLOCKCHAIN.createGenesisBlock(BLOCKCHAIN.calculateNBits())
    :ets.insert(:table,{"Blocks",1,firstBlock})
    amounts = WALLETS.getAllStates()
    assert !(Enum.any?(amounts, fn x-> x != 25 end))
  end

  test "Check for spending > money in wallet" do
    :ets.new(:table, [:bag, :named_table,:public])
    numNodes = 10;
        SSUPERVISOR.start_link(numNodes)
        Enum.each(1..2, fn x-> MINERSERVER.start_link end)
        nbits = BLOCKCHAIN.calculateNBits()
        firstBlock = BLOCKCHAIN.createGenesisBlock(nbits)
        :ets.insert(:table,{"Blocks",1,firstBlock})
        transferAmt = 39
        TRANSACTION.transactionChain(1, transferAmt)
        Process.sleep(200)
        TASKFINDER.run(2, nbits)
  end

  # functional test cases
  #test "transaction from A to B" do
   # MAIN.main(10,1)
   # MAIN.testOutputs()
  #end
end
