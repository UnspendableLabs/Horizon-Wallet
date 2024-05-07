




# Send counterparty native assets  ( Basic )

1) Call compose transaction endpoint with correct params  ( Api.composeSend )
2) Transaction.fromHex with response ( Transaction.fromHex )
3) Call API to get UTXO list ( Api.getUTXOs)
4) Generate UTXO map  ( Util.generateUTXOMap )
5) For each input in parsed transaction that has an entry in UTXO map, 
   sign that input with users private key ( TransactionSigner.sign(inputIndex, keypair, ?, ?, utxo, redeemScript? (bech32 only)) )
   
6) Broadcast tx ( BitcoinNode.broadcast may or may not be a counteparty hosted endpoint )




# Send BTC  ( Basic )

Is this the SAME? 



# Send counterparty native assets ( Advanced )

-2 ) In UI, High, Medium, Low, No priority 
-1 ) Get reecommended fees ( TransactionEstimator.getRecommendFeeForPriority(priority) )
0  ) Estimate confirmation ETA TrawnsactionEstimator.estimateTimeToConfirmation( priority or numblocks ?) )
... everything in basic 






