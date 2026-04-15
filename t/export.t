use strict;
use warnings;
use Test::More;

# Test 1: Default import exports both functions
subtest 'default import exports getUPS and UPStrack' => sub {
    my $pkg = 'Business::UPS::TestDefault';
    eval qq{
        package $pkg;
        use Business::UPS;
        1;
    } or die $@;

    ok( $pkg->can('getUPS'),   'getUPS() imported by default' );
    ok( $pkg->can('UPStrack'), 'UPStrack() imported by default' );
};

# Test 2: Selective import — only UPStrack
subtest 'selective import of UPStrack only' => sub {
    my $pkg = 'Business::UPS::TestSelective';
    eval qq{
        package $pkg;
        use Business::UPS 'UPStrack';
        1;
    } or die $@;

    ok( $pkg->can('UPStrack'),  'UPStrack() imported when requested' );
    ok( !$pkg->can('getUPS'),   'getUPS() not imported when not requested' );
};

# Test 3: Selective import — only getUPS
subtest 'selective import of getUPS only' => sub {
    my $pkg = 'Business::UPS::TestGetUPS';
    eval qq{
        package $pkg;
        use Business::UPS 'getUPS';
        1;
    } or die $@;

    ok( $pkg->can('getUPS'),    'getUPS() imported when requested' );
    ok( !$pkg->can('UPStrack'), 'UPStrack() not imported when not requested' );
};

# Test 4: Empty import list — nothing exported
subtest 'empty import list exports nothing' => sub {
    my $pkg = 'Business::UPS::TestEmpty';
    eval qq{
        package $pkg;
        use Business::UPS ();
        1;
    } or die $@;

    ok( !$pkg->can('getUPS'),   'getUPS() not imported with empty list' );
    ok( !$pkg->can('UPStrack'), 'UPStrack() not imported with empty list' );
};

# Test 5: Requesting a non-existent function dies
subtest 'importing non-existent function dies' => sub {
    eval q{
        package Business::UPS::TestBadImport;
        use Business::UPS 'nonexistent';
    };
    like( $@, qr/not exported/i, 'dies when requesting non-existent export' );
};

# Test 6: VERSION is accessible
subtest 'VERSION is defined' => sub {
    ok( defined $Business::UPS::VERSION, 'VERSION is defined' );
    like( $Business::UPS::VERSION, qr/^\d+\.\d+$/, 'VERSION looks like a version number' );
};

done_testing();
