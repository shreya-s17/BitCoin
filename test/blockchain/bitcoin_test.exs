defmodule Blockchain.Bitcoin do
  use ExUnit.Case, async: false

  setup_all do
    Process.sleep(200)
    numNodes = 8
  nbits = BLOCKCHAIN.calculateNBits()
  BLOCKCHAIN.initializeGenesisBlock(numNodes,nbits)
    IO.puts "Starting Genesis block test cases"
  end

  # unit test cases

test "Create genesis block with initial amount" do
  IO.puts "Create genesis block with initial amount"
  amounts = WALLETS.getAllStates()
  assert !(Enum.any?(amounts, fn x-> x != 25 end))
end

end
