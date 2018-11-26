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

  def transactionChain(numTxns, transferAmt) do
    hashList = :ets.lookup(:table,"PublicKeys")
    |> Enum.map(fn {_, x}->
      x
    end)
    recursivePropagation(numTxns, hashList, transferAmt)
  end

  def recursivePropagation(numTxns, hashList, transferAmt) do
    if(numTxns != 0) do
      WALLETS.updateUnspentAmount()
     generateTxn(hashList, transferAmt,0)
     Process.sleep(100)
     spawn(fn ->recursivePropagation(numTxns-1, hashList,transferAmt ) end)
    else
      Process.sleep(500)
      #IO.inspect :ets.lookup(:table,"unspentTxns")
  #IO.inspect :ets.lookup(:table,"pendingTxns")
      System.halt()
    end
  end

  def generateTxn(hashList, transferAmt,count) do
    if(count >10) do
      IO.puts "Most of the transactions do not have transfer amount"
    else
    address1 = Enum.random(hashList)
    [_,_,unspentAmt] = GenServer.call(String.to_atom("h_"<>address1),{:getState})
    if(unspentAmt == 0) do       # infinite loop for nodes with 0 amount
      generateTxn(hashList, transferAmt,count+1)
    end
    out = WALLETS.getUnspentTxns(address1,transferAmt)
    if(out != NULL) do
      inputtxIds = Enum.map(out, fn [a,x,y,_]->
        [a,x,y]
      end)
      [_, _, _, amount] = Enum.at(out, 0)


      {outputs,fee} = WALLETS.getOutputs(amount, transferAmt, hashList, address1)
      rawTransaction(inputtxIds, outputs, address1, fee)
    end
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
    map = %{sig: "", inputTxIds: [], inputs: {"0",0}, outputs: tx.outputs}
    {"",transRef, 0, map}
  end

  def rawTransaction(inputs, outputs, currNode, transFee) do
    tempInputs = Enum.map(inputs, fn [_,x,y]->
      [x,y]
    end)
    transRef = Enum.reduce(tempInputs ++ outputs, "", fn [str, int], acc ->
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
    inputs1 = Enum.map(inputs, fn [_,a,_]->
      a
    end)
    amt = Enum.reduce(outputs,0, fn [_,a], acc->acc+ a end)
    map = %{sig: scriptSignature, inputTxIds: inputs1, inputs: {currNode, amt+transFee}, outputs: outputs}
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
