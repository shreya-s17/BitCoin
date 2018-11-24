defmodule WALLETS do
  require GENSERVERS

  def updateUnspentAmount(senderNode) do
    map = :ets.lookup(:table,"unspentTxns")
    finalAmount = 0
    Enum.each(map, fn x ->
      # fetch the publickey and check if it is equal.
      #if(recieverPublicKey == senderNode) do # change it using private key
        #finalAmount += amt
      #end
      #GENSERVERS.cast(String.to_atom("h_" <> senderPublicKey), {:updateWallet, amt * -1})
    end)
    GenServer.cast(self(), {:updateWallet, finalAmount})
  end

  def verify_signature(public_key, msg, signature) do
    sig = Base.decode16!(signature)
    pk = Base.decode16!(public_key)
    :crypto.verify(:ecdsa, :sha256, msg, sig, [pk, :secp256k1])
  end

  def getUnspentTxns do

  end
end
