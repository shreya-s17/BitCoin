defmodule WALLETS do
  require GENSERVERS

  def updateUnspentAmount() do
    list = :ets.lookup(:table,"unspentTxns")
    Enum.each(list, fn {_,{_,fee,x}} ->
      ipKey = Map.get(x,:inputPubKey)
      amt = Map.get(x, :amount)
      if(ipKey !="0") do
        GenServer.cast(String.to_atom("h_" <> ipKey), {:updateWallet, (amt + fee)*-1})
      end
      GenServer.cast(String.to_atom("h_" <> Map.get(x,:outPubKey)), {:updateWallet, amt})
    end)
  end

  def verify_signature(public_key, msg, signature) do
    sig = Base.decode16!(signature)
    pk = Base.decode16!(public_key)
    :crypto.verify(:ecdsa, :sha256, msg, sig, [pk, :secp256k1])
  end

  def getUnspentTxns(pubKey, transferAmt) do
    list = :ets.lookup(:table,"unspentTxns")
    inputs = Enum.filter(list, fn {_,{_,_,map}}->
      Map.get(map, :outPubKey) == pubKey
    end)
      #### multiple would create problem
    inputTxns = Enum.reduce(inputs, 0, fn xy, acc ->
      {_,{txid,_,x}} = xy
      acc = acc + Map.get(x, :amount)
      if(acc > transferAmt) do
        [xy, txid, Map.get(x, :amount), acc]
      end
    end)
    [_, _, _,amt] = Enum.at([inputTxns], 0)
    if(amt < transferAmt) do
      IO.puts "Amount to transfer is greater than amount present"
      NULL
    else
      [inputTxns]
    end
  end

  def getOutputs(amount, transferAmt, hashList, address1) do
    list = if(amount - transferAmt > 0.1 * transferAmt) do
      {[[Enum.random(hashList), transferAmt],
      [address1, amount - transferAmt - 0.1 * transferAmt]], 0.1 * transferAmt}
    else
      if(amount - transferAmt - 0.1 * transferAmt >=0) do
      {[[Enum.random(hashList), transferAmt]], 0.1 * transferAmt}
      else
        {[[Enum.random(hashList), transferAmt]], amount - transferAmt}
      end
    end
    list
  end
end
