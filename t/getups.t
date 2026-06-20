use strict;
use warnings;
use Test::More;
use Business::UPS;

# Capture deprecation warnings
my @warnings;
$SIG{__WARN__} = sub { push @warnings, $_[0] };

# Verify no HTTP calls are made — getUPS() should return immediately
# since the endpoint is retired
my $http_called = 0;
{
    no warnings 'redefine';
    *LWP::UserAgent::new = sub { $http_called++; bless {}, 'LWP::UserAgent' };
    *LWP::UserAgent::get = sub { $http_called++; die "should not be called" };
}

subtest 'getUPS emits deprecation warning' => sub {
    @warnings    = ();
    $http_called = 0;

    getUPS(qw/GNDCOM 23606 23607 50/);

    is( scalar @warnings, 1, 'exactly one warning emitted' );
    like( $warnings[0], qr/deprecated/i, 'warning mentions deprecation' );
    like( $warnings[0], qr/qcostcgi/,    'warning mentions retired endpoint' );
};

subtest 'getUPS returns error immediately without HTTP call' => sub {
    @warnings    = ();
    $http_called = 0;

    my ( $shipping, $zone, $error ) = getUPS(qw/GNDCOM 23606 23607 50/);

    is( $shipping, undef, 'no shipping cost' );
    is( $zone,     undef, 'no zone' );
    ok( defined $error,   'error message returned' );
    like( $error, qr/retired/i, 'error explains endpoint is retired' );
    is( $http_called, 0,  'no HTTP request was made' );
};

subtest 'getUPS works with no arguments' => sub {
    @warnings    = ();
    $http_called = 0;

    my ( $shipping, $zone, $error ) = getUPS();

    is( $shipping, undef, 'no shipping cost' );
    is( $zone,     undef, 'no zone' );
    ok( defined $error,   'error returned even with no args' );
    is( $http_called, 0,  'no HTTP request was made' );
};

done_testing();
