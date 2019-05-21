#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use BlockShop;
use BlockShop::Admin;
use BlockShop::Api;

use Plack::Builder;

builder {
    enable 'Deflater';
    BlockShop->to_app;
    BlockShop::Admin->to_app;
    BlockShop::Api->to_app;
}
