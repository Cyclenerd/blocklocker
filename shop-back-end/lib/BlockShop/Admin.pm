package BlockShop::Admin;
use Dancer2 appname => 'BlockShop';
use Dancer2::Plugin::Auth::HTTP::Basic::DWIW;
use POSIX 'log10';

our $VERSION = '0.1';

=head1 NAME

BlockShop::Admin : Administration Interface

=head1 DESCRIPTION

Administration interface for the Blocklocker (Zcash vending machine) prototype.

=head1 METHODS

=cut

=head2 http_basic_auth_set_check_handler

HTTP Basic authentication plugin for Dancer2 that does what I want.

=cut

http_basic_auth_set_check_handler sub {
    my ( $user, $pass ) = @_;
    return $user eq setting('admin_user') && $pass eq setting('admin_password');
};


=head2 PREFIX /admin

=cut

prefix '/admin';


=head2 GET /admin/products

Show products.

=cut

get '/products' => http_basic_auth required => sub {
    my $db = BlockShop::connect_db();
    my $sql = 'SELECT product_id, product_name, ' .
              'product_price_eur, product_price_btc, product_price_eth, product_price_zec, '.
              'product_img_url ' .
              'FROM products ORDER BY product_id';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    template 'products.tt', {
        'title'    => 'Products',
        'products' => $sth->fetchall_hashref('product_id'),
    };
};


=head2 POST /admin/products

Create new product.

=cut

post '/products' => http_basic_auth required => sub {
    my $db = BlockShop::connect_db();
    my $sql = 'INSERT INTO products ('.
                  'product_name, '.
                  'product_img_url, '.
                  'product_price_eur'.
              ') '.
              'VALUES (?, ?, ?)';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
        body_parameters->get('product_name')      || '?', 
        body_parameters->get('product_img_url')   || '',
        body_parameters->get('product_price_eur') || '0',
    ) or die $sth->errstr;

    redirect '/admin/products';
};


=head2 GET /admin/product/:product_id

Show product.

=cut

get '/product/:product_id' => http_basic_auth required => sub {
    my $product_id = int(route_parameters->get('product_id'));
    my $db = BlockShop::connect_db();
    my $sql = 'SELECT product_id, product_name, '.
              'product_price_eur, product_price_btc, product_price_eth, product_price_zec, '.
              'product_img_url '.
              'FROM products '.
              'WHERE product_id LIKE ?';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
        $product_id,
    ) or die $sth->errstr;
    template 'product.tt', {
        'title'      => 'Product',
        'product'    => $sth->fetchrow_hashref(),
    };
};


=head2 POST /admin/product/:product_id

Edit product.

=cut

post '/product/:product_id' => http_basic_auth required => sub {
    my $product_id = int(route_parameters->get('product_id'));
    my $db = BlockShop::connect_db();
    my $sql = 'REPLACE INTO products ('.
                  'product_id, '.
                  'product_name, '.
                  'product_img_url, '.
                  'product_price_eur, '.
                  'product_price_btc, '.
                  'product_price_eth, '.
                  'product_price_zec'.
              ') '.
              'VALUES (?, ?, ?, ?, ?, ?, ?)';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
        $product_id,
        body_parameters->get('product_name')      || '?', 
        body_parameters->get('product_img_url')   || '',
        body_parameters->get('product_price_eur') || '0',
        body_parameters->get('product_price_btc') || '0',
        body_parameters->get('product_price_eth') || '0',
        body_parameters->get('product_price_zec') || '0',
    ) or die $sth->errstr;

    redirect '/admin/products';
};


=head2 DELETE /admin/product/:product_id

Delete product.

=cut

del '/product/:product_id' => http_basic_auth required => sub {
    my $product_id = int(route_parameters->get('product_id'));
    my $db = BlockShop::connect_db();
    my $sql = 'DELETE FROM products '.
              'WHERE product_id LIKE ?';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
        $product_id,
    ) or die $sth->errstr;

    redirect '/admin/products';
};


=head2 GET /admin/locker

Show locker and doors.

=cut

get '/locker' => http_basic_auth required => sub {
    my $db = BlockShop::connect_db();
    my $sql_products = 'SELECT product_id, door_id, product_name, '.
                       'product_price_eur, product_price_btc, product_price_eth, product_price_zec, '.
                       'door_reserved '.
                       'FROM products, locker ' .
                       'WHERE product_id LIKE door_product_id';
    my $sth_products = $db->prepare($sql_products) or die $db->errstr;
    $sth_products->execute or die $sth_products->errstr;
    template 'locker.tt', {
        'title'    => 'Locker',
        'doors'    => setting('doors'), # Number of doors from settings
        'products' => $sth_products->fetchall_hashref('door_id'),
    };
};


=head2 GET /admin/door/:door_id

Show door and product assignment.

=cut

get '/door/:door_id' => http_basic_auth required => sub {
    my $door_id = int(route_parameters->get('door_id'));
    my $db = BlockShop::connect_db();
    my $sql_products = 'SELECT product_id, ' .
                       'product_price_eur, product_price_btc, product_price_eth, product_price_zec, '.
                       'product_name '.
                       'FROM products ORDER BY product_id';
    my $sql_door     = 'SELECT door_id, door_product_id, door_reserved ' .
                       'FROM locker ' .
                       'WHERE door_id LIKE ?';
    my $sth_products = $db->prepare($sql_products) or die $db->errstr;
    my $sth_door   = $db->prepare($sql_door) or die $db->errstr;
    $sth_products->execute or die $sth_products->errstr;
    $sth_door->execute(
        $door_id,
    ) or die $sth_door->errstr;
    template 'door.tt', {
        'title'      => "Door $door_id",
        'door_id'    => $door_id,
        'products'   => $sth_products->fetchall_hashref('product_id'),
        'door'       => $sth_door->fetchrow_hashref(),
    };
};


=head2 POST /admin/door/:door_id

Edit door and product assignment.

=cut

post '/door/:door_id' => http_basic_auth required => sub {
    my $door_id = int(route_parameters->get('door_id'));
    my $db = BlockShop::connect_db();
    my $sql = 'REPLACE INTO locker (door_id, door_product_id, door_reserved) '.
              'VALUES (?, ?, ?)';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
        $door_id,
        body_parameters->get('door_product_id') || '0',
        body_parameters->get('door_reserved')   || '0',
    ) or die $sth->errstr;

    redirect '/admin/locker';
};


=head2 DELETE /admin/door/:door_id

Delete door and product assignment.

=cut

del '/door/:door_id' => http_basic_auth required => sub {
    my $door_id = int(route_parameters->get('door_id'));
    my $db = BlockShop::connect_db();
    my $sql = 'DELETE FROM locker '.
              'WHERE door_id LIKE ?';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
        $door_id,
    ) or die $sth->errstr;

    redirect '/admin/locker';
};


=head2 POST /admin/open/:door_id

Open door.

=cut

post '/open/:door_id' => http_basic_auth required => sub {
    my $door_id = int(route_parameters->get('door_id'));
    BlockShop::open_door($door_id);
    return "Door $door_id is open";
};


=head2 GET /admin/sales

Show sales and status.

=cut

get '/sales' => http_basic_auth required => sub {
    my $db = BlockShop::connect_db();
    my $sql = 'SELECT sale_id, sale_product_id, sale_door_id, '.
              'sale_price_eur, sale_price_btc, sale_price_eth, sale_price_zec, '.
              'sale_zcash_address, sale_status, sale_timestamp, product_name ' .
              'FROM sales, products ' .
              'WHERE sale_product_id LIKE product_id';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    template 'sales.tt', {
        'title'    => 'Sales',
        'sales'    => $sth->fetchall_hashref('sale_id'),
    };
};


=head2 GET /admin/zcash

Information about the current state of the Zcash block chain.

=cut

get '/zcash' => sub {
    my $zec = BlockShop::connect_zcash();
    my $getblockchaininfo = $zec->getblockchaininfo;
    template 'zcash.tt', { 
        'title' => 'Zcash Blockchain',
        'getblockchaininfo' => $getblockchaininfo,
    };
};


=head2 GET /admin/zcash/:zcash_address

Show balance of a taddr or zaddr belonging to the Zcash node’s wallet with confirmations >= 1.

=cut

get '/zcash/:zcash_address' => http_basic_auth required => sub {
    my $zcash_address = route_parameters->get('zcash_address');
    my $zec = BlockShop::connect_zcash();
    my $z_getbalance = '?';
    my $z_listreceivedbyaddress = [];
    my $z_validateaddress = $zec->z_validateaddress( $zcash_address );
    if ( $z_validateaddress && $z_validateaddress->{'isvalid'} && $z_validateaddress->{'ismine'} ) {
        my $confirmations = BlockShop::zcash_confirmations();
        $z_getbalance = $zec->z_getbalance($zcash_address, $confirmations);
        $z_listreceivedbyaddress = $zec->z_listreceivedbyaddress( $zcash_address, $confirmations );
    }
    template 'zcash_address.tt', {
        'title' => 'Zcash Address',
        'zcash_address' => $zcash_address,
        'z_getbalance' => $z_getbalance,
        'z_listreceivedbyaddress' => $z_listreceivedbyaddress,
    };
};


=head2 GET or POST /admin/cashout

Send funds to cold wallet

=cut

any ['get', 'post'] => '/cashout' => http_basic_auth required => sub {
    my $really_pay_off = body_parameters->get('really') || '', 
    my $db = BlockShop::connect_db();
    my $zec = BlockShop::connect_zcash();
    # All transactions / addresses from the past
    my $sql = 'SELECT sale_id, sale_status, '.
              'sale_price_eur, sale_price_btc, sale_price_eth, sale_price_zec, '.
              'sale_zcash_address, sale_timestamp ' .
              'FROM sales '.
              'WHERE sale_status >  1 '.
              'AND   sale_status != 8 ';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute() or die $sth->errstr;
    my $sales = $sth->fetchall_hashref('sale_id');
    my $zcash_cash_out_address = setting( 'zcash_cash_out_address' ) || 'zcash_cash_out_address MISSING !';
    my $zcash_cash_out_fee = setting( 'zcash_cash_out_fee' ) || '0.0001';
    $zcash_cash_out_fee = $zcash_cash_out_fee + 0; # string to number
    my @balances = ();
    foreach my $sale_id ( keys %{$sales} ) {
        my $sale_status        = $sales->{$sale_id}->{sale_status};
        my $sale_timestamp     = $sales->{$sale_id}->{sale_timestamp};
        my $sale_zcash_address = $sales->{$sale_id}->{sale_zcash_address};
        my $z_validateaddress = $zec->z_validateaddress( $sale_zcash_address || '' );
        if ( $z_validateaddress && $z_validateaddress->{'isvalid'} && $z_validateaddress->{'ismine'} ) {
            my $z_getbalance_confirmed = $zec->z_getbalance( $sale_zcash_address, BlockShop::zcash_confirmations() );
            my $z_sendmany = '';
            if ($really_pay_off && $zcash_cash_out_address && $z_getbalance_confirmed > 0) {
                my $amount = $z_getbalance_confirmed - $zcash_cash_out_fee;
                my @amounts = (
                    {
                        address => $zcash_cash_out_address,
                        amount  => $amount,
                    },
                );
                $z_sendmany = $zec->z_sendmany( $sale_zcash_address, [@amounts], BlockShop::zcash_confirmations(), $zcash_cash_out_fee );
                debug "[CASH OUT] $sale_zcash_address : $amount ZEC (Fee : $zcash_cash_out_fee) OPID: $z_sendmany";
            }
            push @balances, {
                'sale_id'        => $sale_id,
                'sale_status'    => $sale_status,
                'zcash_address'  => $sale_zcash_address,
                'zcash_opid'     => $z_sendmany,
                'balance_zec'    => $z_getbalance_confirmed,
                'sale_timestamp' => $sale_timestamp,
            };
        }
    }
    template 'cashout.tt', {
        'title' => 'Cash Out',
        'zcash_cash_out_address' => $zcash_cash_out_address,
        'zcash_cash_out_fee' => $zcash_cash_out_fee,
        'balances' => \@balances,
    };
};


=head2 GET /admin/reorg

Reorganize all current sales (sale_status = 1).
Set new status and release, if necessary, the reservation of the door.

=cut

get '/reorg' => http_basic_auth required => sub {
    my $db = BlockShop::connect_db();
    my $zec = BlockShop::connect_zcash();
    my $sql = 'SELECT sale_id, sale_status, '.
              'sale_price_eur, sale_price_btc, sale_price_eth, sale_price_zec, '.
              'sale_zcash_address, sale_timestamp ' .
              'FROM sales '.
              'WHERE sale_status LIKE 1 ' .
              'OR sale_status LIKE 8';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    my $sales = $sth->fetchall_hashref('sale_id');
    
    my $timestamp = time;
    
    foreach my $sale_id ( keys %{$sales} ) {
        my $sale_id            = $sales->{$sale_id}->{sale_id};
        my $sale_status        = $sales->{$sale_id}->{sale_status};
        my $sale_zcash_address = $sales->{$sale_id}->{sale_zcash_address};
        my $sale_price_zec     = $sales->{$sale_id}->{sale_price_zec};
        my $sale_timestamp     = $sales->{$sale_id}->{sale_timestamp};
        my $z_validateaddress = $zec->z_validateaddress( $sale_zcash_address || '' );
        if ( $z_validateaddress && $z_validateaddress->{'isvalid'} && $z_validateaddress->{'ismine'} ) {
            my $z_getbalance           = $zec->z_getbalance( $sale_zcash_address, 0 );
            my $z_getbalance_confirmed = $zec->z_getbalance( $sale_zcash_address, BlockShop::zcash_confirmations() );
            my $new_status = '';
            # Complete the purchase and release the door
            if ( $sale_status == 8 && $timestamp > $sale_timestamp + BlockShop::open_door_until() ) {
                $new_status = '9';
            }
            # Payment not in the set period
            elsif ( $z_getbalance < $sale_price_zec && $timestamp > $sale_timestamp + BlockShop::zcash_payment_until() ) {
                $new_status = '2';
            }
            # Full payment not confirmed within the specified period
            elsif ( $z_getbalance_confirmed < $sale_price_zec && $timestamp > $sale_timestamp + BlockShop::zcash_confirmation_until() ) {
                $new_status = '3';
            }
            # Door not open in the period
            elsif ( $timestamp > $sale_timestamp + BlockShop::open_door_until() ) {
                $new_status = '4';
            }
            # Save new status
            if ($new_status) {
                my $sql_status = "UPDATE sales SET sale_status = ? WHERE sale_id LIKE ?";
                my $sth_status = $db->prepare($sql_status) or die $db->errstr;
                $sth_status->execute(
                    $new_status,
                    $sale_id,
                ) or die $sth_status->errstr;
                if ($new_status != '9') {
                    # 2,3,4 = Remove reservation
                    my $sql_door = "UPDATE locker SET door_reserved = 0 WHERE door_reserved LIKE ?";
                    my $sth_door = $db->prepare($sql_door) or die $db->errstr;
                    $sth_door->execute($sale_id) or die $sth_door->errstr;
                } else {
                    # 9 = Delete assignment product to door
                    my $sql_door = 'DELETE FROM locker WHERE door_reserved LIKE ?';
                    my $sth_door = $db->prepare($sql_door) or die $db->errstr;
                    $sth_door->execute($sale_id) or die $sth_door->errstr;
                }
            }
        }
    }
    
    return 'DONE';
};


=head2 GET /admin/convert

Update BTC, ETH and ZEC product prices.

=cut

get '/convert' => http_basic_auth required => sub {
    my $db = BlockShop::connect_db();
    my $ua = BlockShop::connect_http();
    
    # api: https://coinmarketcap.com/api/
    # get id: https://api.coinmarketcap.com/v2/listings/
    my @currencies = (
        #Bitcoin (BTC)
        {
            'id'   => '1',                 # coinmarketcap id
            'name' => 'bitcoin',           # website_slug name
            'sql'  => 'product_price_btc', # sql field name
        },
        # Ethereum (ETH)
        {
            'id'   => '1027',
            'name' => 'ethereum',
            'sql'  => 'product_price_eth',
        },
        # Zcash (ZEC)
        {
            'id'   => '1437',
            'name' => 'zcash',
            'sql'  => 'product_price_zec',
        },
    );
    
    foreach my $currency ( @currencies ) {
        my $coin_id            = $currency->{'id'};
        my $coin_name          = $currency->{'name'};
        my $product_price_coin = $currency->{'sql'};
        my $api_url = 'https://api.coinmarketcap.com/v2/ticker/'.$coin_id.'/?convert=EUR';
        my $api_data = $ua->get( $api_url ) or die "Unable to GET CoinMarketCap JSON: $!";
        if ($api_data->content =~ m|EUR|g) {
            my $api_json = from_json( $api_data->content );
            my $website_slug = $api_json->{'data'}->{'website_slug'};
            my $coin_eur_price = $api_json->{'data'}->{'quotes'}->{'EUR'}->{'price'};
            my $eur_coin_price = 1 / $coin_eur_price;
            my $coin_round = sprintf "%.0f", log10($coin_eur_price)+2;
            $coin_round = 3 if ($coin_round < 3);
            if ( $eur_coin_price && $coin_name eq $website_slug ) { # Update only if the website_slug name matches
                # Update price
                debug "[CONVERT] 1 $coin_name = $coin_eur_price EUR / 1 EUR = $eur_coin_price // Round: $coin_round";
                my $sql = "UPDATE products SET $product_price_coin = ROUND(product_price_eur*$eur_coin_price, $coin_round)";
                my $sth = $db->prepare($sql) or die $db->errstr;
                $sth->execute or die $sth->errstr;
            }
        } else {
            send_error('price_eur not found');
        }
    }
    
    return 'DONE';
};


true;
