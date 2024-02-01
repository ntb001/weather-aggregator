use strict;
use warnings;

use Config::Tiny;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'models/forecast.pl';
require 'clients/httpclient.pl';

my $config = Config::Tiny->read('config.ini');
die 'config.ini not found.' unless $config;

my $api_key = $config->{accuweather}{api};
die 'API Key for AccuWeather.com not found in config.ini' unless $api_key;

# https://developer.accuweather.com/accuweather-forecast-api/apis/get/forecasts/v1/daily/5day/%7BlocationKey%7D

sub get_accuweather {
    my ( $lat, $lon ) = @_;

    # translate lat,lon into location key
    my $client = HttpClient->new(
'http://dataservice.accuweather.com/locations/v1/cities/geoposition/search'
    );
    $client->addQueryParam( 'apikey', $api_key );
    $client->addQueryParam( 'q',      "$lat,$lon" );
    my $json         = $client->getJson();
    my $location_key = $json->{Key};

    # get forecast
    $client = HttpClient->new(
"http://dataservice.accuweather.com/forecasts/v1/daily/5day/$location_key"
    );
    $client->addQueryParam( 'apikey',  $api_key );
    $client->addQueryParam( 'details', 'true' );
    $json = $client->getJson();

    my @results = ();
    foreach my $period ( @{ $json->{DailyForecasts} } ) {
        my $entry = Forecast->new(
            'accuweather',
            $lat,
            $lon,
            $period->{EpochDate},
            $period->{Temperature}{Maximum}{Value},
            $period->{Day}{Wind}{Speed}{Value},
            $period->{Day}{Wind}{Direction}{English},
            $period->{Day}{PrecipitationProbability},
        );
        push( @results, $entry );
    }
    return @results;
}

1;
