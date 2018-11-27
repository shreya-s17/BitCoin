defmodule BITCOINTest do
  use ExUnit.Case, async: false

  setup_all do
    IO.puts ""
  end

  test "Validate for spending > money in wallet" do
    IO.puts "Check for spending > money in wallet"
    Process.sleep(200)
    numNodes = 4
    TRANSACTION.testSetup(numNodes)
    Enum.each(1..2, fn _-> MINERSERVER.start_link end)
    nbits = BLOCKCHAIN.calculateNBits()
    transferAmt = 39
    TRANSACTION.transactionChain(1, transferAmt)
    Process.sleep(200)
    TASKFINDER.run(2, nbits, 0)
    assert :ets.lookup(:table, "Error") == []
  end

  test "Validate null transactions" do
    IO.puts "Validate null transactions"
    Process.sleep(200)
    numNodes = 4
    TRANSACTION.testSetup(numNodes)
    Enum.each(1..2, fn _-> MINERSERVER.start_link end)
    nbits = BLOCKCHAIN.calculateNBits()
    TRANSACTION.transactionChain(0, 0)
    Process.sleep(200)
    TASKFINDER.run(2, nbits, 0)
    assert :ets.lookup(:table, "Error") != []
  end

  test "Validate invalid money range transactions" do
    IO.puts "Validate invalid money range transactions"
    Process.sleep(200)
    numNodes = 4
    TRANSACTION.testSetup(numNodes)
    Enum.each(1..2, fn _-> MINERSERVER.start_link end)
    nbits = BLOCKCHAIN.calculateNBits()
    TRANSACTION.transactionChain(1, -5)
    Process.sleep(200)
    TASKFINDER.run(2, nbits, 0)
    assert :ets.lookup(:table, "Error") != []
  end

end
