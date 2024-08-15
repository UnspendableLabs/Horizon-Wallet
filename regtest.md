
1) Configure and run a bitcoind test instance


```
# this is just an example, don't copy all of these params obviously 
❯ cat /bitcoin/data/bitcoin.regtest.conf
regtest=1
datadir=/bitcoin/data
rpcuser=rpc
rpcpassword=rpc
server=1
addresstype=legacy
txindex=1
prune=0
mempoolfullrbf=1
rpcworkqueue=100
allowignoredconf=1
#improve sync speed
listen=1
dbcache=4000


zmqpubhashtx=tcp://127.0.0.1:28832
zmqpubrawblock=tcp://127.0.0.1:28832
zmqpubrawtx=tcp://127.0.0.1:28832
zmqpubsequence=tcp://127.0.0.1:28832
```

2) Point addrindexrs to bitcoind instance 

```
# from addrindexrs repo 
# NOTE: we have to set port explicitly because there is a mismatch in default across addrindexrs and core

❯ ./target/release/addrindexrs -vvv --network regtest  --cookie="rpc:rpc" --indexer-rpc-port 28432

```

3) Start counterparty core

```
# note that we need to set bitcoind port explicitly as core's default is out of date
❯ counterparty-server start -vvv --regtest --backend-port 18443
```

4) Create a wallet

```
bitcoin-cli -regtest createwallet <WALLET_NAME>

```

5) Get a bech32 address and generate blocks that send btc to it

```
bitcoin-cli -regtest -rpcwallet=<WALLET_NAME> getnewaddress "" "bech32"
bitcoin-cli -regtest -rpcwallet=<WALLET_NAME> generatetoaddress <NUM_BLOCKS> <ADDRESS>

```

6) Compose a burn, sign, and submit

```
curl http://localhost:24000/v2/addresses/bcrt1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej/compose/burn?quantity=<SATS>
bitcoin-cli -rpcwallet=<WALLET_NAME> -regtest signrawtransactionwithwallet <RAW_HEX>
bitcoin-cli -rpcwallet=<WALLET_NAME> -regtest sendrawtransaction <SIGNED_HEX> 

# NOTE, the tx is just in the mempool so we need to mine
bitcoin-cli -regtest -generate 1
```

7) Get private key 
```
bitcoin-cli -regtest -rpcwallet=<WALLET_NAME> listdescriptors true
```

8) Start UI 

```
# checkout activity-feed branch ( you may need to install flutter / dart sdk ) 

flutter run -d Chrome --dart-define=REG_TEST_PK=<YOUR_PK> --dart-define=REG_TEST_PW=<ANY_PASSWORD_YOU_WANT>

```

9) Have fun

At this point you'll have a single account, you can also create a new one.  This is useful for testing sends / receives.

A few things to keep in mind:

1) Submitted transactions will be in the mempool until you generate a new block with:
```
bitcoin-cli -regtest -generate <1 || <ARB_NUM_BLOCKS>>
```
2) it is useful to test sends by creating a second account and sending to addresses in that account
3) It is recommended to test with network tab open for now 
4) this workflow bypasses onboarding.  to test that, do not set REG_TEST env vars or just checkout `main`
5) BTC Sends are supported but don't show up in activity feed. 

# incomplete list of known issues
- i think there is some floating point weirdness in balances display
- server errors are not always propagated through to the UI ( see note 3 above )

