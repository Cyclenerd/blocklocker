BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `sales` (
    `sale_id`               INTEGER PRIMARY KEY AUTOINCREMENT,
    `sale_product_id`       INTEGER NOT NULL DEFAULT 0,
    `sale_door_id`          INTEGER NOT NULL DEFAULT 0,
    `sale_price_eur`        NUMERIC NOT NULL DEFAULT 0,
    `sale_price_btc`        NUMERIC NOT NULL DEFAULT 0,
    `sale_price_eth`        NUMERIC NOT NULL DEFAULT 0,
    `sale_price_zec`        NUMERIC NOT NULL DEFAULT 0,
    `sale_bitcoin_address`  TEXT    NOT NULL DEFAULT '',
    `sale_ethereum_address` TEXT    NOT NULL DEFAULT '',
    `sale_zcash_address`    TEXT    NOT NULL DEFAULT '',
    `sale_status`           INTEGER NOT NULL DEFAULT 0,
    `sale_timestamp`        INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS `products` (
    `product_id`        INTEGER PRIMARY KEY AUTOINCREMENT,
    `product_name`      TEXT    NOT NULL DEFAULT '',
    `product_img_url`   TEXT    NOT NULL DEFAULT '',
    `product_price_eur` NUMERIC NOT NULL DEFAULT 0,
    `product_price_btc` NUMERIC NOT NULL DEFAULT 0,
    `product_price_eth` NUMERIC NOT NULL DEFAULT 0,
    `product_price_zec` NUMERIC NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS `locker` (
    `door_id`         INTEGER NOT NULL,
    `door_product_id` INTEGER NOT NULL DEFAULT 0,
    `door_reserved`   INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY(`door_id`)
);
COMMIT;
