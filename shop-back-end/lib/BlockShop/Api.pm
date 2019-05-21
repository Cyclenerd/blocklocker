package BlockShop::Api;
use Dancer2 appname => 'BlockShop';

our $VERSION = '0.1';

=head1 NAME

BlockShop::Api : Application Programming Interface

=head1 DESCRIPTION

API for the Blocklocker (Zcash vending machine) prototype.

=head1 METHODS

=cut


=head2 PREFIX /api/v1

=cut

prefix '/api/v1';


=head2 GET /api/v1/door

Information about the current state of door locker as JSON.

=cut

get '/door' => sub {
    BlockShop::open_door(); # Test door locker
    send_as JSON => { 
        'status'   => 'OK', 
        'location' => setting('door_location') || '',
    };
};


=head2 GET /api/v1/zcash

Information about the current state of the Zcash block chain as JSON.

=cut

get '/zcash' => sub {
    my $zec = BlockShop::connect_zcash();
    my $getblockchaininfo = $zec->getblockchaininfo;
    send_as JSON => $getblockchaininfo;
};


=head2 GET /api/v1/shop

Return JSON with products for sale.

JSON example output: examples/shop.json

Test:

    curl "http://localhost:5000/api/v1/shop"

=cut

get '/shop' => sub {
    my $db = BlockShop::connect_db();
    my $sql = 'SELECT product_id, product_name, product_img_url, '.
              'product_price_eur, product_price_btc, product_price_eth, product_price_zec, '.
              'COUNT(door_product_id) AS number_available ' .
              'FROM locker, products ' .
              'WHERE door_product_id LIKE product_id ' .
              'AND door_reserved < 1 '.
              'AND product_price_eur > 0 '.
              'AND product_price_btc > 0 '.
              'AND product_price_eth > 0 '.
              'AND product_price_zec > 0 '.
              'GROUP BY product_id';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    send_as JSON => $sth->fetchall_hashref('product_id');
};


=head2 GET /api/v1/product/:product_id

Return JSON with details of one product.
Also returns unavailable products.

JSON example output: examples/product.json

=cut

get '/product/:product_id' => sub {
    my $product_id = int(route_parameters->get('product_id'));
    my $db = BlockShop::connect_db();
    my $sql = 'SELECT product_id, product_name, product_img_url, '.
              'product_price_eur, product_price_btc, product_price_eth, product_price_zec, '.
              'COUNT(door_product_id) AS number_available ' .
              'FROM locker, products ' .
              'WHERE door_product_id LIKE product_id ' .
              'AND product_id LIKE ?' .
              'AND door_reserved < 1 '.
              'AND product_price_eur > 0 '.
              'AND product_price_btc > 0 '.
              'AND product_price_eth > 0 '.
              'AND product_price_zec > 0 '.
              'GROUP BY product_id';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
        $product_id,
    ) or die $sth->errstr;
    send_as JSON => $sth->fetchrow_hashref(),
};


=head2 GET /api/v1/buy/zcash/:product_id

Buy the product with payment option Zcash return JSON.

JSON example output: examples/buy_zcash.json

Test:

    curl "http://localhost:5000/api/v1/buy/zcash/2"

=cut

get '/buy/zcash/:product_id' => sub {
    my $product_id = int(route_parameters->get('product_id'));
    my $db = BlockShop::connect_db();
    my $zec = BlockShop::connect_zcash();

    # Get one product
    my $sql_product = 'SELECT product_id, product_name, '.
              'product_price_eur, product_price_btc, product_price_eth, product_price_zec, '.
              'door_id '.
              'FROM locker, products '.
              'WHERE door_product_id LIKE product_id '.
              'AND door_reserved < 1 '.
              'AND product_price_eur > 0 '.
              'AND product_price_zec > 0 '.
              'AND product_id LIKE ? '.
              'LIMIT 1';
    my $sth_product = $db->prepare($sql_product) or die $db->errstr;
    $sth_product->execute($product_id) or die $sth_product->errstr;
    my $product = $sth_product->fetchrow_hashref();
    my $door_id = $product->{door_id};
    my $product_price_zec = $product->{product_price_zec};

    # Create new Zcash Address for sale
    my $zcash_type    = setting('zcash_type') eq 'sapling' ? 'sapling' : 'sprout';
    my $zcash_address = $zec->z_getnewaddress($zcash_type);

    # Get current timestamp
    my $timestamp = time;

    # Create new sale
    my $sale_id = '';
    if ($door_id && $zcash_address && $product_price_zec > 0) { # Check the ZEC price twice. Better safe than sorry
        my $sql_sale = 'INSERT INTO sales ('.
                           'sale_product_id, '.
                           'sale_door_id, '.
                           'sale_price_eur, '.
                           'sale_price_btc, '.
                           'sale_price_eth, '.
                           'sale_price_zec, '.
                           'sale_zcash_address, '.
                           'sale_status, '.
                           'sale_timestamp'.
                       ') '.
                       'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
        my $sth_sale = $db->prepare($sql_sale) or die $db->errstr;
        $sth_sale->execute(
            $product->{product_id},
            $product->{door_id},
            $product->{product_price_eur},
            $product->{product_price_btc},
            $product->{product_price_eth},
            $product->{product_price_zec},
            $zcash_address,
            '1',
            $timestamp
        ) or die $sth_sale->errstr;
        $sale_id = $db->last_insert_id("","","",""); # Get last AI id

        # Reserve product behind door
        if ($sale_id) {
            my $sql = 'UPDATE locker '.
                      'SET door_reserved = ?'. 
                      'WHERE door_id LIKE ?';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute(
                $sale_id,
                $door_id,
            ) or die $sth->errstr;
        } else {
            die "Can not reserve product";
        }
    } else {
        die "Can not create sale";
    }

    send_as JSON => { 
        'price_zec'              => $product->{product_price_zec},
        'zcash_address'          => $zcash_address,
        'timestamp'              => $timestamp,
        'payment_until'          => $timestamp + BlockShop::zcash_payment_until(),
        'confirmation_until'     => $timestamp + BlockShop::zcash_confirmation_until(),
        'open_until'             => $timestamp + BlockShop::open_door_until(),
        'required_confirmations' => BlockShop::zcash_confirmations(),
    };
};


=head2 GET /api/v1/status/zcash/:zchash_address

Return JSON with balance of a taddr or zaddr belonging to the node’s wallet with confirmations:

0, 1, 2, 3, and 4

JSON example output: examples/status_zcash.json

Test:

    curl "http://localhost:5000/api/v1/status/zcash/ztsJ5qh2pWgRUjy2qvUrw2eKrG1iipRj5Hjt1QCNPZDf9aToya3B9qXdVY6Cn3hTp9aq7KQdT63Zin53YRL5gBnJQVQjtxJ"

=cut

get '/status/zcash/:zcash_address' => sub {
    my $zcash_address = route_parameters->get('zcash_address');
    my $zec = BlockShop::connect_zcash();
    my %z_getbalance = (
        '0' => '0',
        '1' => '0',
        '2' => '0',
        '3' => '0',
        '4' => '0',
    );
    my %z_listreceivedbyaddress = (
        '0' => '0',
        '1' => '0',
        '2' => '0',
        '3' => '0',
        '4' => '0',
    );
    my $z_validateaddress = $zec->z_validateaddress( $zcash_address );
    if ( $z_validateaddress && $z_validateaddress->{'isvalid'} && $z_validateaddress->{'ismine'} ) {
        my $db = BlockShop::connect_db();
        my $sql = 'SELECT sale_id, sale_status, sale_product_id, sale_door_id, '.
                  'sale_price_zec, '.
                  'sale_zcash_address, sale_status, sale_timestamp ' .
                  'FROM sales ' .
                  'WHERE sale_zcash_address LIKE ? '.
                  'LIMIT 1';
        my $sth = $db->prepare($sql) or die $db->errstr;
        $sth->execute(
            $zcash_address,
        ) or die $sth->errstr;
        my $sale = $sth->fetchrow_hashref();
        my $required_confirmations = BlockShop::zcash_confirmations();
        my %confirmations = ();
        foreach my $confirmation ( 0..$required_confirmations+10 ) {
            my $z_getbalance              = $zec->z_getbalance($zcash_address, $confirmation);
            my $z_listreceivedbyaddress   = $zec->z_listreceivedbyaddress( $zcash_address, $confirmation );
            $confirmations{$confirmation} = { 
                'confirmations' => $confirmation,
                'balance'       => $z_getbalance,
                'transactions'  => $z_listreceivedbyaddress,
            }
        }
        send_as JSON => {
            'status'                 => $sale->{sale_status},
            'price_zec'              => $sale->{sale_price_zec},
            'zcash_address'          => $sale->{sale_zcash_address},
            'timestamp'              => time,
            'payment_until'          => $sale->{sale_timestamp} + BlockShop::zcash_payment_until(),
            'confirmation_until'     => $sale->{sale_timestamp} + BlockShop::zcash_confirmation_until(),
            'open_until'             => $sale->{sale_timestamp} + BlockShop::open_door_until(),
            'required_confirmations' => $required_confirmations,
            'confirmations'          => \%confirmations,
        };
    } else {
        send_error('Zcash address not valid', 400);
    }
};


=head2 GET /api/v1/open/zcash/:zchash_address

Open door after successful and confirmed Zcash payment

JSON example output: examples/open_zcash.json

Test:

    curl "http://localhost:5000/api/v1/open/zcash/ztsJ5qh2pWgRUjy2qvUrw2eKrG1iipRj5Hjt1QCNPZDf9aToya3B9qXdVY6Cn3hTp9aq7KQdT63Zin53YRL5gBnJQVQjtxJ"

=cut

get '/open/zcash/:zcash_address' => sub {
    my $zcash_address = route_parameters->get('zcash_address');
    my $zec = BlockShop::connect_zcash();
    my $z_validateaddress = $zec->z_validateaddress( $zcash_address );
    if ( $z_validateaddress && $z_validateaddress->{'isvalid'} && $z_validateaddress->{'ismine'} ) {
        my $db = BlockShop::connect_db();
        my $sql = 'SELECT sale_id, sale_product_id, sale_door_id, '.
                  'sale_price_zec, '.
                  'sale_zcash_address, sale_status, sale_timestamp ' .
                  'FROM sales ' .
                  'WHERE sale_zcash_address LIKE ? '.
                  'LIMIT 1';
        my $sth = $db->prepare($sql) or die $db->errstr;
        $sth->execute(
            $zcash_address,
        ) or die $sth->errstr;
        my $sale = $sth->fetchrow_hashref();
        my $sale_id        = $sale->{sale_id};
        my $sale_door_id   = $sale->{sale_door_id};
        my $sale_price_zec = $sale->{sale_price_zec};
        my $sale_status    = $sale->{sale_status};
        my $timestamp = time;
        if ( $sale_status == 1 || $sale_status == 8 ) {
            my $z_getbalance = $zec->z_getbalance( $zcash_address, BlockShop::zcash_confirmations() );
            if ( $z_getbalance >= $sale_price_zec ) {
                BlockShop::open_door($sale_door_id);
                # Update status
                my $sql_status = "UPDATE sales SET sale_status = ? WHERE sale_id LIKE ?";
                my $sth_status = $db->prepare($sql_status) or die $db->errstr;
                $sth_status->execute(
                    '8',
                    $sale_id,
                ) or die $sth_status->errstr;
                # Return JSON
                send_as JSON => {
                    'open' => true,
                    'door' => $sale_door_id,
                };
            } else {
                send_error('Amount not yet fully paid', 402);
            }
        } else {
            send_error('Not paid or late. Door already open or not during the period.', 403);
        }
    } else {
        send_error('Zcash address not valid', 400);
    }
};


true;
