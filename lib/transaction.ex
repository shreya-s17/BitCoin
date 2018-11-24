defmodule TRANSACTION do
  require GENSERVERS

  defstruct [
    :hash,
    # a list of list of the form [[previous_tx_hash, output_index]]
    :inputs,
    :public_key,
    :signature,
    # a list of list of the form [[recipient, value]]
    :outputs
  ]

  def transactionChain(numTxns) do
    # add amount in coinbase txn.
    hashList = :ets.lookup(:table,"PublicKeys")
    |> Enum.map(fn x->
      {_, {val}} = x
      val
    end)
    coinBase(Enum.random(hashList))
    IO.puts " coinbase done"
    recursivePropagation(numTxns, hashList)
  end

  def recursivePropagation(numTxns, hashList) do
    if(numTxns != 0) do
      generateTxn(hashList)
      recursivePropagation(numTxns-1, hashList)
    end
  end

  def generateTxn(hashList) do
    address1 = Enum.random(hashList)
    WALLETS.updateUnspentAmount(address1)     # can cause problem as only one is getting updated
    [_,_,unspentAmt,_] = GenServer.call(self(),{:getState})
    if(unspentAmt == 0) do    # infinite loop for nodes with 0 amount
      generateTxn(hashList)
    end
    address2 = Enum.random(hashList)
    map = Map.new()
    txs = WALLETS.getUnspentTxns()
    inputtxId = Enum.map(txs, fn x->
      [txid, _] = x
      txid
    end)
    rawTransaction(txs, inputtxId, address2, unspentAmt/2, map)
  end

  def coinBase(output) do
    tx = %TRANSACTION{
      outputs: [[output, 50]],
      inputs: [["0", 0]]
    }
    transRef = Enum.reduce(tx.inputs ++ tx.outputs, "", fn [str, int], acc ->
      acc <> str <> Integer.to_string(int)
    end)
    |> KEYGENERATION.hash(:sha256)
    transRef
  end

  def rawTransaction(inputtx,inputtxId, outPubKey, amount, map) do
    [privateKey, publicKey_unhashed] = GenServer.call(self(),{:getState})

    # Txn INPUT
    rawTransactionOut =
    "01" # number of inputs
    <> inputtxId  # txid of previous outputs
    <> "00000000"    # outpoint of the previous  txn
    <> inputtx[5].length()   # Script String temp
    <> inputtx[5] # ScriptPubKey of output
    <> "01" # number of outputs in txn
    <> amount - 0.0001   # amount in hexa -----------------

    # Txn OUTPUT
    <> outPubKey.length()   # Script Sign
    <> outPubKey # next node's public key

    |> KEYGENERATION.hash(:sha256)
    |> KEYGENERATION.hash(:sha256)

    signedHash = sign(rawTransactionOut,privateKey)

    # Script String
    scriptSignature = signedHash.length() + 1
    <> signedHash
    <> "01"
    <> publicKey_unhashed

    Map.put(map, :numOfInputs, "01")    # number of inputs
    Map.put(map, :inputTxId, inputtxId)   # txid of previous outputs
    Map.put(map, :outpoint, "00000000")     # outpoint of the previous  txn
    Map.put(map, :scriptLen, scriptSignature.length() -1)   # Script String temp
    Map.put(map, :script, scriptSignature)
    Map.put(map, :numOfOutputs, "01")   # number of outputs in txn
    Map.put(map, :amount, amount - 0.0001)   # amount in hexa -----------------
    Map.put(map, :outPubKeyLen, outPubKey.length())   # Script Sign
    Map.put(map, :outPubKey, outPubKey) # next node's public key

    out1 = Map.values(map)
    |> Enum.reduce(fn x, acc-> acc <> x end)

    :ets.insert(:table, {"pendingTxns", {out1 |> KEYGENERATION.hash(:sha256)
      |> KEYGENERATION.hash(:sha256), map}})
  end

  def sign(val, key) do
    signedHash = :crypto.sign(:ecdsa, :sha256, val,
      [Base.decode16!(key), :secp256k1])
    |> KEYGENERATION.hash(:sha256)
    signedHash
  end

  def randomString(length) do
    charList = Enum.map(1..length, fn _ ->
      Enum.random(['A','B','C','D','E','F','0','1','2','3','4','5','6','7','8','9'])
    end)
    List.to_string(charList)
  end
end
