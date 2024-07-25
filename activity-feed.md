1) when user submits a tx, it is stored locally and shows up in the feed
2) poll mempool  ( mempool transactions won't have blocktime )
2a) dedupe mempool / 
3) We continuously poll /addresses/transactions ( confirmed transactions will have a blocktime)
4) We can deduplicate transactions by tx hash



# when user first logs in

- query local ( there are  none )
- query confirmed ( there are some )
- dedupe


# questions
- will "source" always refer to users addy? likely


# requirements
- balances and transactions should update at same interval
- DisplayTransaction





