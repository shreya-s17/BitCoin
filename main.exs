defmodule MAIN do
  :ets.new(:table, [:bag, :named_table,:public])
  SSUPERVISOR.start_link(2)
  IO.puts "Genservers started"
  TRANSACTION.transactionChain(2)
end
