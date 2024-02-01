use strict;
use warnings;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'clients/httpclient.pl';

sub addressToCoordinates {
    my ($address) = @_;

    my $client = HttpClient->new('https://nominatim.openstreetmap.org/search');
    $client->addQueryParam( 'format', 'json' );
    $client->addQueryParam( 'q',      $address );
    my $json   = $client->getJson();
    my $result = $json->[0];
    die "No location found for $address." unless $result;

    my $lat = $result->{lat};
    my $lon = $result->{lon};
    return ( $lat, $lon );
}

1;
