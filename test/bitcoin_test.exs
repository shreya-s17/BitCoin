defmodule BITCOINTest do
  use ExUnit.Case

  # unit test cases
  test "Create genesis block with initial amount" do
    :ets.new(:table, [:bag, :named_table,:public])
    numNodes = 10;
    SSUPERVISOR.start_link(numNodes)
    Enum.each(1..2, fn x-> MINERSERVER.start_link end)
    IO.puts "Test Case 1"
    firstBlock = BLOCKCHAIN.createGenesisBlock(BLOCKCHAIN.calculateNBits())
    :ets.insert(:table,{"Blocks",1,firstBlock})
    amounts = WALLETS.getAllStates()
    #IO.inspect amounts
    assert !(Enum.any?(amounts, fn x-> x != 25 end))
  end

  test "Validate the block creation" do
    :ets.new(:table, [:bag, :named_table,:public])
    numNodes = 10;
    SSUPERVISOR.start_link(numNodes)
    Enum.each(1..2, fn x-> MINERSERVER.start_link end)
    IO.puts "Test Case 2"
    nbits = BLOCKCHAIN.calculateNBits()
    firstBlock = BLOCKCHAIN.createGenesisBlock(nbits)
    :ets.insert(:table,{"Blocks",1,firstBlock})
    IO.puts "printing final block"
    transferAmt = Enum.random(1..24)
    TRANSACTION.transactionChain(2, transferAmt)
    Process.sleep(200)
    TASKFINDER.run(2, nbits)
  end

  # functional test cases
  #test "transaction from A to B" do
   # MAIN.main(10,1)
   # MAIN.testOutputs()
  #end
end
