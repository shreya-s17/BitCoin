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

  def getUnspentTxns do

  end
end
