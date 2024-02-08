use strict;
use warnings;

use Redis;

sub getRedis {
    my ($key) = @_;
    my $redis = Redis->new( server => 'redis:6379' );
    my $value = $redis->get($key);
    return $value;
}

sub setRedis {
    my ( $key, $value ) = @_;
    my $redis = Redis->new( server => 'redis:6379' );
    $redis->set( $key, $value );
}

sub setRedisTtl {
    my ( $key, $value ) = @_;
    my $redis = Redis->new( server => 'redis:6379' );
    $redis->setex( $key, 3600, $value );
}

1;
