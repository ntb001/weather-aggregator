use strict;
use warnings;

use Redis;

my $server = 'redis:6379';

sub cacheGet {
    my ($key) = @_;
    my $redis = Redis->new( server => $server );
    my $value = $redis->get($key);
    return $value;
}

sub cacheSet {
    my ( $key, $value ) = @_;
    my $redis = Redis->new( server => $server );
    $redis->set( $key, $value );
}

sub cacheSetTtl {
    my ( $key, $value ) = @_;
    my $redis = Redis->new( server => $server );
    $redis->setex( $key, 3600, $value );
}

1;
