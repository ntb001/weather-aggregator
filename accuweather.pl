use strict;
use warnings;

use Config::Tiny;
use URI;
use URI::QueryParam;
use LWP::UserAgent ();
use JSON;

my $config = Config::Tiny->read('config.ini');
die 'config.ini not found.' unless $config;

my $api_key = $config->{accuweather}{api};
die 'API Key for AccuWeather.com not found in config.ini' unless $api_key;

# https://developer.accuweather.com/accuweather-forecast-api/apis/get/forecasts/v1/daily/5day/%7BlocationKey%7D

sub get_accuweather {
    my ( $lat, $lon ) = @_;

    # translate lat,lon into location key
    my $url = URI->new(
'http://dataservice.accuweather.com/locations/v1/cities/geoposition/search'
    );
    $url->query_param_append( 'apikey', $api_key );
    $url->query_param_append( 'q',      "$lat,$lon" );
    my $ua       = LWP::UserAgent->new();
    my $response = $ua->get( $url->as_string );
    $response->is_success or die $response->status_line;
    my $json         = $response->decoded_content;
    my $decoded_json = decode_json($json);
    my $location_key = $decoded_json->{Key};

    # get forecast
    $url = URI->new(
"http://dataservice.accuweather.com/forecasts/v1/daily/5day/$location_key"
    );
    $url->query_param_append( 'apikey',  $api_key );
    $url->query_param_append( 'details', 'true' );
    $response = $ua->get( $url->as_string );
    $response->is_success or die $response->status_line;
    $json         = $response->decoded_content;
    $decoded_json = decode_json($json);

    my @results = ();
    foreach my $period ( @{ $decoded_json->{DailyForecasts} } ) {
        my %entry = (
            source         => 'accuweather',
            latitude       => $lat,
            longitude      => $lon,
            utc_time       => $period->{EpochDate},
            temperature    => $period->{Temperature}{Maximum}{Value},
            wind_speed     => $period->{Day}{Wind}{Speed}{Value},
            wind_direction => $period->{Day}{Wind}{Direction}{English},
            precipitation  => $period->{Day}{PrecipitationProbability},
        );
        push( @results, \%entry );
    }
    return @results;
}

1;
