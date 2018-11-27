# BITCOIN

**Distributed ledger protocol for cryptocurrency**

## Group info
| Name  | UFID  |
|---|---|
| Amruta Basrur | 44634819  |
|  Shreya Singh| 79154462  |

## Instructions

1. Unzip Amruta_Shreya.zip file and navigate to Amruta_Shreya folder.
2. Open the command promt and enter the below mix command to compile and run the code.
</br>**Input:** Enter mix test
</br> This is the input for running all the test cases.
</br>**Output:**  12 tests, 0 failures</br>
</br> This is the test case result
3. **Input:**
mix test</br>
**Output**
</br>Starting test cases
</br>Test case 2
</br>.Test case 6
</br>.Test case 3
</br>.Test case 4
</br>.Test case 5
</br>..Starting test cases
</br>Test case 1
</br>..
</br>Finished in 2.0 seconds
</br>12 tests, 0 failures</br></br>
5. Working:</br>
	1. 	The test cases provide input arguments to the program and validate the results  </br>
	2. 	The Coinbase transaction starts the network and initially each node is given a fixed amount of 25 </br>
	3.	The genesis block is created first and the inputs have been fixed for the block </br>
	4. 	As soon as a node gets a request to transfer the amount to the other node, the node uses the reciever's Public key and the transaction IDs of the transactions which are available with it. It also checks the amount available in the wallet. And then the transaction is created by hashing and signing using public keys. ECC has been used to generate the key-pair. </br>
  5.  The transaction is then moved to the list of pending transactions and the miners begin working on it to mine the transaction. </br>
	6. 	The largest number of nodes being tested for block chain is 100 nodes and maximum number of requests tested is 100</br>