use strict;
use warnings;

use Redis;

sub getRedis {
    my ($key) = @_;
    my $redis = Redis->new;
    my $value = $redis->get($key);
    if ($value) {
        print "Redis get $key: $value\n";
    }
    else {
        print "Redis miss $key\n";
    }
    return $value;
}

sub setRedis {
    my ( $key, $value ) = @_;
    my $redis = Redis->new;
    $redis->set( $key, $value );
    print "Redis set $key: $value\n";
}

sub setRedisTtl {
    my ( $key, $value ) = @_;
    my $redis = Redis->new;
    $redis->setex( $key, 3600, $value );
    print "Redis set $key: $value for 1 hour\n";
}

1;
