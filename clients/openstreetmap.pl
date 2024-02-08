use strict;
use warnings;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'clients/httpclient.pl';
require 'clients/redisclient.pl';

sub addressToCoordinates {
    my ($address) = @_;

    my $cacheKey = "openstreetmap/$address";
    $cacheKey =~ s/ /_/g;    # spaces to underscores
    my $latlon = getRedis($cacheKey);
    if ($latlon) {
        my @array = split( "/", $latlon );
        return ( $array[0], $array[1] );
    }

    my $client = HttpClient->new('https://nominatim.openstreetmap.org/search');
    $client->addQueryParam( 'format', 'json' );
    $client->addQueryParam( 'q',      $address );
    my $json   = $client->getJson();
    my $result = $json->[0];
    die "No location found for $address." unless $result;

    my $lat = $result->{lat};
    my $lon = $result->{lon};
    $latlon = "$lat/$lon";
    setRedis( $cacheKey, $latlon );

    return ( $lat, $lon );
}

1;
