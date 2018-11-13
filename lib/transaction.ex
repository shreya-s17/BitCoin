defmodule TRANSACTION do
  def coinBase do

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
