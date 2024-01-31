use strict;
use warnings;

use URI;
use URI::QueryParam;
use LWP::UserAgent ();
use JSON;
use DateTime;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'accuweather.pl';
require 'weatherapi.pl';
require 'weathergov.pl';

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

sub get_forecasts {
    my ($address) = @_;
    my ( $lat, $lon ) = address_to_coordinates($address);

    my @weathergov  = get_weather_gov( $lat, $lon );
    my @accuweather = get_accuweather( $lat, $lon );
    my @weatherapi  = get_weatherapi( $lat, $lon );
    my @results     = ( @weathergov, @accuweather, @weatherapi, );
    my @sorted      = sort { $a->{utc_time} <=> $b->{utc_time} } @results;
    return @sorted;
}

# demo
my @results = get_forecasts("Fishers Island, NY");
foreach my $result (@results) {
    foreach my $key ( keys %{$result} ) {
        my $value = $result->{$key};
        if ( $key eq 'utc_time' ) {
            my $time = DateTime->from_epoch($value);
            $value = $time->rfc3339;
        }
        print("$key: $value\n");
    }
    print("\n");
}
