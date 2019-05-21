package BlockShop;
use Dancer2;
use DBI;
use Zcash::RPC::Client;
use LWP::UserAgent;

our $VERSION = '0.1';

=head1 NAME

BlockShop : Blocklocker Back End

=head1 DESCRIPTION

Back end for the Blocklocker (Zcash vending machine) prototype.

=head1 METHODS

=cut


=head2 connect_http

Create web browser

=cut

sub connect_http {
    my $ua = LWP::UserAgent->new();
    $ua->agent('BlockLockerShopBot/1.0');
    $ua->timeout("15"); # timeout value in seconds
    return $ua;
}


=head2 connect_db

Open SQLite database.

=cut

sub connect_db {
    my $dbh = DBI->connect("dbi:SQLite:dbname=".setting('database')) or
        die $DBI::errstr;
    return $dbh;
}


=head2 connect_zcash

Connect to Zcash RPC.

=cut

sub connect_zcash {
    my $zec = Zcash::RPC::Client->new(
        host     => setting('zcash_rpc_host')     || 'localhost',
        port     => setting('zcash_rpc_port')     || '8232',
        user     => setting('zcash_rpc_user')     || 'username',
        password => setting('zcash_rpc_password') || 'password',
    );
    return $zec;
}


=head2 zcash_payment_until

# Payment (not confirmations) within ? sec

=cut

sub zcash_payment_until {
    my $zcash_payment_until = 15*60;
    if ( setting('zcash_payment_until') ) {
        $zcash_payment_until = setting('zcash_payment_until')*60;
    }
    return int($zcash_payment_until);
}


=head2 zcash_confirmations

Required confirmations so that payment is considered received

=cut

sub zcash_confirmations {
    my $zcash_confirmation = 1;
    if ( setting('zcash_confirmation') && setting('zcash_confirmation') < 5 ) {
        $zcash_confirmation = setting('zcash_confirmation');
    }
    return int($zcash_confirmation);
}


=head2 zcash_confirmation_until

# Payment confirmations within ? sec

=cut

sub zcash_confirmation_until {
    my $zcash_confirmation_until = 15*60;
    if ( setting('zcash_confirmation_until') ) {
        $zcash_confirmation_until = setting('zcash_confirmation_until')*60;
    }
    return int($zcash_confirmation_until);
}


=head2 open_door_until

Open door within ? sec

=cut

sub open_door_until {
    my $open_until = 60*60;
    if ( setting('open_until') ) {
        $open_until = setting('open_until')*60;
    }
    return int($open_until);
}


=head2 open_door

Send door open command to Raspberry Pi via SSH tunnel.

Local port 8000 <-- SSH tunnel --> Rasperry Pi port 80

=cut

sub open_door {
    my ( $door_id ) = @_;
    if ( setting('door_fake') ) {
        debug "[OPEN DOOR] Demo mode (fake_door) is on !!! Door is not really opened.";
    } else {
        my $ua = connect_http();
        my $url = 'http://127.0.0.1:8000/index.sh';
        if ($door_id) {
            $url .= '?door='.$door_id;
        }
        debug "[OPEN DOOR] URL: $url";
        my $response = $ua->get($url);
        my %response = %$response;
        if ( $response{'_rc'} =~ '200' ) {
            # OK
        } elsif ( $response{'_rc'} =~ '429' ) {
            send_error('Door already open. Please wait.', 429);
        } else {
            send_error('Can not open door');
        }
    }
    return 1;
}


prefix undef;


=head2 GET /

Index

=cut

get '/' => sub {
    template 'index.tt';
    # send_file '/index.html'
};


true;
