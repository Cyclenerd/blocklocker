# Blocklocker

This is repository of the "Blocklocker" project.
Blocklocker is composed of the words Blockchain and Locker.
With this project a **prototype** of a simple vending machine was developed.
Payment is made with the [Zcash](https://z.cash/) cryptocurrency.
Other currencies can also be added.

It is the result of an innovation project within the Otto Group IT (IT service provider of the [Otto Group](https://www.ottogroup.com/)).
In the Otto Group IT, employees have the opportunity to suggest innovative projects and then work on them within their working hours.
The innovation does not have to have anything to do with the actual job. Great place to work :)


## Overview

Blocklocker is made up of three main components:

1. [Shop back end with Zcash full node](/shop-back-end/README.md)
2. [Shop front end](/shop-front-end/README.md) - Many thanks to [Marc](https://github.com/mschleeweiss) for the UI.
3. [Locker](/locker/README.md)

```
 +----------+                              Firewall
 | Customer |                                 ||
 +----------+                                 ||
      |                                       ||
      | HTTP                                  ||
      v                                       ||
 +----------------------------------+         ||        +-----------+
 |  Computer with Internet          |         ||        | Locker    |
 |                                  |         ||        +-----+-----+
 |  +----------+     +-----------+  |         ||        |  1  |  2  |
 |  | Shop     |     | Shop      |  |         ||        +-----+-----+
 |  | Back End | <-- | Front End |  |         ||        |  3  |  4  |
 |  +----------+     +-----------+  |         ||        +-----+-----+
 |      |                           |         ||        |  5  |  6  |
 |      | JSON RPC                  |         ||        +-----+-----+
 |      v                           |         ||        |  7  |  8  |
 |  +----------------------------+  |                   +-----+-----+
 |  | Zcash Blockchain Full Node |  | <-- SSH Tunnel -- | Raspberry |
 |  +----------------------------+  |                   | Pi        |
 +----------------------------------+         ||        +-----------+
```


## Process

1. There are up to 8 products in the vending machine / locker. The product is assigned to the door in the shop back end.
2. A customer visits the shop frond end and chooses a product. This will generate and display a Zcash address (z-Addr).
3. The customer sends the displayed amount to the address.
4. Once the transaction has been confirmed, the door can be opened.


## TODO

* More and better documentation
* Refund: https://github.com/zcash/zcash/blob/master/doc/payment-disclosure.md

## Help 👍

If you have found a bug (English is not my mother tongue) or have any improvements, send me a pull request.