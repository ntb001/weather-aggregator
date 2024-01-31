use strict;
use warnings;

use URI;
use URI::QueryParam;
use LWP::UserAgent ();
use JSON;

sub address_to_coordinates {
    my ($address) = @_;

    my $url = URI->new('https://nominatim.openstreetmap.org/search');
    $url->query_param_append( 'format', 'json' );
    $url->query_param_append( 'q',      $address );

    my $ua       = LWP::UserAgent->new();
    my $response = $ua->get( $url->as_string );
    die $response->status_line unless $response->is_success;

    my $json         = $response->decoded_content;
    my $decoded_json = decode_json($json);
    my $result       = $decoded_json->[0];
    die "No location found for $address." unless $result;

    my $lat = $result->{lat};
    my $lon = $result->{lon};

    return ( $lat, $lon );
}
