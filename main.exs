defmodule MAIN do
  :ets.new(:publicKeys, [:set, :protected])
  SSUPERVISOR.start_link(2)
  TRANSACTION.coinBase()
end
