use strict;
use warnings;

use Redis;

sub getRedis {
    my ($key) = @_;
    my $redis = Redis->new;
    my $value = $redis->get($key);
    return $value;
}

sub setRedis {
    my ( $key, $value ) = @_;
    my $redis = Redis->new;
    $redis->set( $key, $value );
}

sub setRedisTtl {
    my ( $key, $value ) = @_;
    my $redis = Redis->new;
    $redis->setex( $key, 3600, $value );
}

1;
