defmodule Blockchain.BlockchainTest do
  use ExUnit.Case, async: false

  setup_all do
    BLOCKCHAIN.testSetup()
    IO.puts "Starting Blockchain Test Cases"
  end

  # unit test cases

  test "Mine next Block" do
    IO.puts "Mine next Block"
    Process.sleep(400)
    WALLETS.updateUnspentAmount()
    transferAmt = Enum.random(1..24)
    nbits = BLOCKCHAIN.calculateNBits()
    TRANSACTION.createInitialTransactions(transferAmt, 1, nbits)
    list= :ets.lookup(:table, "Blocks")
    assert MINERSERVER.validateEntireBlockChain(list)
end

test "Validate Block Chain" do
    IO.puts "Validate Block Chain"
    list= :ets.lookup(:table, "Blocks")
    assert MINERSERVER.validateEntireBlockChain(list)
end

test "Validate only first Block is Genesis Block" do
    IO.puts "Only first Block is Genesis Block"
    list= :ets.lookup(:table, "Blocks")
    #IO.inspect list
    {_,_,[_,flist,_,_]} = Enum.at(list,0)

    value = Enum.all?(Enum.slice(list, 1..-1), fn {_,_,[_,m,_,_]}->
        Map.get(m, :previousBlockHash) !=  "0000000000000000000000000000000000000000000000000000000000000000"
        end)
    assert Map.get(flist, :previousBlockHash) ==  "0000000000000000000000000000000000000000000000000000000000000000"
    assert value == true
end

test "Perform proof of work" do
  IO.puts "Proof of work"
  list= :ets.lookup(:table, "Blocks")
    if(MINERSERVER.validateEntireBlockChain(list) && BLOCKCHAIN.validateAllHash(list) && MINERSERVER.validateTransactionList(list)
    && BLOCKCHAIN.validateMerkleRoot(list)) do
      assert true
    else
      assert false
    end
end

test " Validate Block Hash less than difficulty target" do
  IO.puts "Block Hash less than difficulty target"
  list= :ets.lookup(:table, "Blocks")
  assert BLOCKCHAIN.validateAllHash(list)
end

test "Wallet succesfully updated after a transaction" do
  IO.puts "Wallet succesfully updated after a transaction"
  Process.sleep(400)
  WALLETS.updateUnspentAmount()
  transferAmt = Enum.random(1..5)
  nbits = BLOCKCHAIN.calculateNBits()
  TRANSACTION.createInitialTransactions(transferAmt, 1, nbits)
  WALLETS.updateUnspentAmount()
  assert true
end

test "Validate All mined unspent transactions exists in unspent transactions" do
  IO.puts "All mined transactions had inputs from unspent transactions"
  WALLETS.updateUnspentAmount()
  list= :ets.lookup(:table, "Blocks")
  assert MINERSERVER.existsTransactions(list)
end

test "Validate Merkle Root" do
  IO.puts "Validate Merkle Root"
  list= :ets.lookup(:table, "Blocks")
  assert BLOCKCHAIN.validateMerkleRoot(list)
end

test "Validate all mined transactions to be in proper bitcoin format" do
  IO.puts "Validate all mined transactions to be in proper bitcoin format"
  list= :ets.lookup(:table, "Blocks")
  assert MINERSERVER.validateTransactionList(list)
end

test "Validate hash > difficulty target" do
  IO.puts "Validate hash > difficulty target"
  list= :ets.lookup(:table, "Blocks")
  assert BLOCKCHAIN.validateAllHash(list)
end

test "Validate only 1st Transaction is coinbase per block" do
  IO.puts "Only 1st Transaction is coinbase per block"
  list= :ets.lookup(:table, "Blocks")
  assert BLOCKCHAIN.validateAllHash(list)
end

end
