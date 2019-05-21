# Ordering Process


TIP: Get some TAZ (ZEC on testnet): https://faucet.testnet.z.cash/


## 1.) GET /api/v1/shop

```
$ curl "http://shop-back-end.local/api/v1/shop"
```

JSON:

```
{
  "2": {
    "product_price_eth": 0.00444,
    "product_price_eur": 3,
    "product_price_btc": 0.000364,
    "product_price_zec": 0.0117,
    "product_id": 2,
    "product_name": "Beer",
    "number_available": 2,
    "product_img_url": "https://media.giphy.com/media/l0MYrZOf3nGchoTdK/giphy.gif"
  },
  "1": {
    "product_name": "H20",
    "product_img_url": "https://media.giphy.com/media/unFLKoAV3TkXe/giphy.gif",
    "number_available": 3,
    "product_price_eur": 0.5,
    "product_price_btc": 6.1e-05,
    "product_price_eth": 0.00074,
    "product_id": 1,
    "product_price_zec": 0.0019
  }
}
```


### 1.1.) GET /api/v1/product/:product_id

```
$ curl "http://shop-back-end.local/api/v1/product/1"
```

JSON:

```
{
  "product_id": 1,
  "product_price_zec": 0.0019,
  "product_price_eur": 0.5,
  "product_price_btc": 6.1e-05,
  "product_price_eth": 0.00074,
  "number_available": 3,
  "product_img_url": "https://media.giphy.com/media/unFLKoAV3TkXe/giphy.gif",
  "product_name": "H20"
}
```


## 2.) GET /api/v1/buy/zcash/:product_id

```
$ curl "http://shop-back-end.local/api/v1/buy/zcash/1"
```

JSON:

```
{
  "timestamp": 1525546094,
  "price_zec": 0.0019,
  "payment_until": 1525546994,
  "confirmation_until": 1525547894,
  "open_until": 1525549694,
  "required_confirmations": 1,
  "zcash_address": "ztqSvq3Lu3NH78K76Y5v8pVnH2b6X7SbmYqwfT83EvZhDYZpNmyZneRwpGHNwJFq4STiAJWcpRg9uB5z1wwcrmw6CryZsYo"
}
```


## 3.) Payment

```
# Send funds
$ zcash-cli z_sendmany "ztsJ5qh2pWgRUjy2qvUrw2eKrG1iipRj5Hjt1QCNPZDf9aToya3B9qXdVY6Cn3hTp9aq7KQdT63Zin53YRL5gBnJQVQjtxJ" "[{\"amount\": 0.0021, \"address\": \"ztqSvq3Lu3NH78K76Y5v8pVnH2b6X7SbmYqwfT83EvZhDYZpNmyZneRwpGHNwJFq4STiAJWcpRg9uB5z1wwcrmw6CryZsYo\"}]"
# Get operation status
$ zcash-cli z_getoperationstatus [\"opid-492a2079-e4a6-4539-98c7-4f2e7d301f69\"]
```


## 4.) GET /api/v1/status/zcash/:zchash_address

```
$ curl "http://shop-back-end.local/api/v1/status/zcash/ztqSvq3Lu3NH78K76Y5v8pVnH2b6X7SbmYqwfT83EvZhDYZpNmyZneRwpGHNwJFq4STiAJWcpRg9uB5z1wwcrmw6CryZsYo"
```

JSON:

```
{
  "required_confirmations": 1,
  "confirmation_until": 1525547894,
  "zcash_address": "ztqSvq3Lu3NH78K76Y5v8pVnH2b6X7SbmYqwfT83EvZhDYZpNmyZneRwpGHNwJFq4STiAJWcpRg9uB5z1wwcrmw6CryZsYo",
  "timestamp": 1525546278,
  "status": 1,
  "open_until": 1525549694,
  "confirmations": {
    "3": {
      "confirmations": "3",
      "transactions": [],
      "balance": 0
    },
    "4": {
      "balance": 0,
      "transactions": [],
      "confirmations": "4"
    },
    "0": {
      "transactions": [
        {
          "memo": "f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "jsoutindex": 1,
          "jsindex": 0,
          "txid": "d3b14ddd41e79239c0784eb7324fd86be3e8cbad20a27f6d3be50e83313de95d",
          "amount": 0.0021
        }
      ],
      "balance": 0.0021,
      "confirmations": "0"
    },
    "1": {
      "confirmations": "1",
      "transactions": [],
      "balance": 0
    },
    "2": {
      "transactions": [],
      "balance": 0,
      "confirmations": "2"
    }
  },
  "payment_until": 1525546994,
  "price_zec": 0.0019
}
```


### Status Codes

1. Order initiated
2. Payment not within the specified period
3. Payment not confirmed within the specified period
4. Door not opened within the specified period
5. -/-
6. -/-
7. -/-
8. Door opened
9. Purchase completed


After about 4 minutes:

```
{
  "timestamp": 1525546392,
  "status": 1,
  "zcash_address": "ztqSvq3Lu3NH78K76Y5v8pVnH2b6X7SbmYqwfT83EvZhDYZpNmyZneRwpGHNwJFq4STiAJWcpRg9uB5z1wwcrmw6CryZsYo",
  "required_confirmations": 1,
  "confirmation_until": 1525547894,
  "payment_until": 1525546994,
  "price_zec": 0.0019,
  "open_until": 1525549694,
  "confirmations": {
    "3": {
      "confirmations": "3",
      "transactions": [],
      "balance": 0
    },
    "4": {
      "confirmations": "4",
      "balance": 0,
      "transactions": []
    },
    "0": {
      "transactions": [
        {
          "jsoutindex": 1,
          "memo": "f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "txid": "d3b14ddd41e79239c0784eb7324fd86be3e8cbad20a27f6d3be50e83313de95d",
          "jsindex": 0,
          "amount": 0.0021
        }
      ],
      "balance": 0.0021,
      "confirmations": "0"
    },
    "1": {
      "confirmations": "1",
      "balance": 0.0021,
      "transactions": [
        {
          "memo": "f600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "jsoutindex": 1,
          "amount": 0.0021,
          "jsindex": 0,
          "txid": "d3b14ddd41e79239c0784eb7324fd86be3e8cbad20a27f6d3be50e83313de95d"
        }
      ]
    },
    "2": {
      "confirmations": "2",
      "transactions": [],
      "balance": 0
    }
  }
}
```

Required confirmations (`required_confirmations`) fulfilled. Door can be opened.


## 5.) GET /api/v1/open/zcash/:zchash_address

```
curl "http://shop-back-end.local/api/v1/open/zcash/ztqSvq3Lu3NH78K76Y5v8pVnH2b6X7SbmYqwfT83EvZhDYZpNmyZneRwpGHNwJFq4STiAJWcpRg9uB5z1wwcrmw6CryZsYo"
```

JSON:

```
{
  "open": 1,
  "door": 1
}
```
