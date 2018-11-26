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
    hashList = :ets.lookup(:table,"PublicKeys")
    |> Enum.map(fn {_, x}->
      x
    end)
    recursivePropagation(numTxns, hashList)
  end

  def recursivePropagation(numTxns, hashList) do
    if(numTxns != 0) do
     generateTxn(hashList)
     spawn(fn ->recursivePropagation(numTxns-1, hashList) end)
    end
  end

  def generateTxn(hashList) do
    address1 = Enum.random(hashList)
    [_,_,unspentAmt] = GenServer.call(String.to_atom("h_"<>address1),{:getState})
    if(unspentAmt == 0) do    # infinite loop for nodes with 0 amount
      generateTxn(hashList)
    end
    transferAmt = Enum.random(1..24)
    out = WALLETS.getUnspentTxns(address1,transferAmt)
    if(out != NULL) do
    [_, _, _, amount] = Enum.at(out, 0)

    inputtxIds = Enum.map(out, fn [_,x,y,_]->
      [x,y]
    end)
    {outputs,fee} = WALLETS.getOutputs(amount, transferAmt, hashList, address1)
    rawTransaction(inputtxIds, transferAmt, outputs, address1, fee)
    end
  end

  def coinBase(output, amount) do
    tx = %TRANSACTION{
      outputs: [[output, amount]],      # amount to be sent by coinbase transaction
      inputs: [["0", 0]]
    }
    transRef = Enum.reduce(tx.inputs ++ tx.outputs, "", fn [str, int], acc ->
      acc <> str <> Float.to_string(int/1)
    end)
    |> KEYGENERATION.hash(:sha256)
    |> KEYGENERATION.hash(:sha256)
    |> Base.encode16()
    map = %{inputTxId: "0", inputPubKey: "0", outpoint: 0, amount: amount, outPubKey: output}
    {"",transRef, 0, map}
  end

  def rawTransaction(inputs, transferAmt, outputs, currNode, transFee) do
    transRef = Enum.reduce(inputs ++ outputs, "", fn [str, int], acc ->
      acc <> str <> Float.to_string(int/1)
    end)
    |> KEYGENERATION.hash(:sha256)
    |> KEYGENERATION.hash(:sha256)
    |> Base.encode16()

    [privateKey, publicKey, _] = GenServer.call(String.to_atom("h_" <> currNode),{:getState})

    signedHash = sign(publicKey, privateKey) |> Base.encode16

    # Script String
    scriptSignature = Integer.to_string(String.length(signedHash) + 1)
    <> signedHash
    <> "01"
    <> publicKey

    map = %{sig: scriptSignature, inputPubKey: inputs, outPubKey: outputs}
    :ets.insert(:table, {"pendingTxns", transRef, transFee, map})
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
