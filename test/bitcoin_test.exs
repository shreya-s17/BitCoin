defmodule BITCOINTest do
  use ExUnit.Case, async: true

  setup_all do
    IO.puts "Starting test cases"
  end

  # unit test cases
  test "Create genesis block with initial amount" do
    IO.puts "Test case 1"
    :ets.new(:table, [:bag, :named_table,:public])
    numNodes = 10;
    SSUPERVISOR.start_link(numNodes)
    Enum.each(1..2, fn x-> MINERSERVER.start_link end)
    firstBlock = BLOCKCHAIN.createGenesisBlock(BLOCKCHAIN.calculateNBits())
    :ets.insert(:table,{"Blocks",1,firstBlock})
    amounts = WALLETS.getAllStates()
    assert !(Enum.any?(amounts, fn x-> x != 25 end))
  end

  test "Validate the block creation" do
    IO.puts "Test case 2"
    :ets.new(:table, [:bag, :named_table,:public])
    numNodes = 10;
    SSUPERVISOR.start_link(numNodes)
    Enum.each(1..2, fn x-> MINERSERVER.start_link end)
    nbits = BLOCKCHAIN.calculateNBits()
    firstBlock = BLOCKCHAIN.createGenesisBlock(nbits)
    :ets.insert(:table,{"Blocks",1,firstBlock})
    transferAmt = Enum.random(1..24)
    TRANSACTION.transactionChain(2, transferAmt)
    Process.sleep(200)
    TASKFINDER.run(2, nbits, 0)
  end

  #test "Check for spending > money in wallet" do
   # firstBlock = BLOCKCHAIN.createGenesisBlock(BLOCKCHAIN.calculateNBits())
   # :ets.insert(:table,{"Blocks",1,firstBlock})
   # transferAmt = 39
   # TRANSACTION.transactionChain(1, transferAmt)             # think for a way to pass it
  #end
end
