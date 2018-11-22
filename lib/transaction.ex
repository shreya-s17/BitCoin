defmodule TRANSACTION do

  def transactionChain do
    coinBaseTransactionRef = coinBase()
    # create txn into unspent list
    # add amount in coinbase txn.
  end

  def coinBase do
    coinBaseTransactionRef = Enum.reduce(1..256, "", fn _, acc -> acc <> "0" end) <> #Prev output txn
    Enum.reduce(1..32, "", fn _,acc -> acc <> "F" end) <> #Prev output index
    "00011110" <>   # Bytes in coinbase
    "01" <>         # Bytes in height
    "00000000" <> # from amruta # Height
    "00011110" <> randomString(30) <>   # Arbitrary data script
    "00000000"      # Sequence
    coinBaseTransactionRef
  end

  def rawTransaction(input_txids, out_pub_key_hash, amount) do
    [privateKey, publicKey_unhashed] = GENSERVERS.call(self(), {:getState})
    # Txn input
    "01000000" <>   # Version
    "01" <>         # number of inputs
    "00000000" <>     # number of outputs in txn

      # Txn Outpoint
      input_txids <>   # txid of previous outputs
      "00000000" <>    # outpoint of the txn

      # signature
      input_txids <>
      "00000000" <>
      #prevPublicScript # TODO has pubkey of present node
      out_pub_key_hash <> # outputs puKey script
      amount

      # signature script which is not signed but signs the above
      privateKey <>
      publicKey_unhashed <>
      KEYGENERATION.to_public_hash(publicKey_unhashed)

  end

  def randomString(length) do
    charList = Enum.map(1..length, fn _ ->
      Enum.random(['A','B','C','D','E','F','0','1','2','3','4','5','6','7','8','9'])
    end)
    List.to_string(charList)
  end

  def transactionInformation do

    #hash, input_size, output_size
    #details of input: prev_output {hash}
    #proof of previous transaction: script signature
    #details of output: value, PublicKey
  end

  #Transaction chain -
  # name of Transaction = SHA(SHA(msg))
  #History of ownership
  #Inputs: Bitcoins from many transaction
  #proof of meeting condition, private key
  #output with change
  #encoded transaction block - name of the transaction
end
