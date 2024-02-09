use strict;
use warnings;

use Redis;

# my $server = 'redis:6379';

sub cacheGet {
    my ($key) = @_;
    my $redis = Redis->new();
    my $value = $redis->get($key);
    return $value;
}

sub cacheSet {
    my ( $key, $value ) = @_;
    my $redis = Redis->new();
    $redis->set( $key, $value );
}

sub cacheSetTtl {
    my ( $key, $value ) = @_;
    my $redis = Redis->new();
    $redis->setex( $key, 3600, $value );
}

1;
