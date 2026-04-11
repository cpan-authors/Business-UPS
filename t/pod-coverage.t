use strict;
use warnings;
use Test::More;

plan skip_all => 'Author tests not required for installation'
    unless $ENV{AUTHOR_TESTING};

eval 'use Test::Pod::Coverage 1.08';
plan skip_all => 'Test::Pod::Coverage 1.08 required' if $@;

all_pod_coverage_ok();
