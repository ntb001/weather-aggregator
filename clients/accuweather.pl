use strict;
use warnings;

use Config::Tiny;
use Future::AsyncAwait;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'models/forecast.pl';
require 'clients/httpclient.pl';
require 'clients/redisclient.pl';

my $config = Config::Tiny->read('config.ini');
die 'config.ini not found.' unless $config;

my $api_key = $config->{accuweather}{api};
die 'API Key for AccuWeather.com not found in config.ini' unless $api_key;

# https://developer.accuweather.com/accuweather-forecast-api/apis/get/forecasts/v1/daily/5day/%7BlocationKey%7D

sub _getLocationKey {
    my ( $lat, $lon ) = @_;

    # try cache
    my $cacheKey    = "accuweather/$lat,$lon";
    my $locationKey = getRedis($cacheKey);
    return $locationKey if ($locationKey);

    # translate lat,lon into location key
    my $client = HttpClient->new(
'http://dataservice.accuweather.com/locations/v1/cities/geoposition/search'
    );
    $client->addQueryParam( 'apikey', $api_key );
    $client->addQueryParam( 'q',      "$lat,$lon" );
    my $json = $client->getJson();
    $locationKey = $json->{Key};

    setRedis( $cacheKey, $locationKey );
    return $locationKey;
}

async sub getAccuWeather {
    my ( $lat, $lon ) = @_;

    my $locationKey = _getLocationKey( $lat, $lon );
    my $results     = ForecastList->new();

    # try cache
    my $cacheKey = "accuweather/$locationKey";
    my $json     = getRedis($cacheKey);
    if ($json) {
        $results->fromJson($json);
        return $results;
    }

    # get forecast
    my $client = HttpClient->new(
"http://dataservice.accuweather.com/forecasts/v1/daily/5day/$locationKey"
    );
    $client->addQueryParam( 'apikey',  $api_key );
    $client->addQueryParam( 'details', 'true' );
    $json = $client->getJson();

    foreach my $period ( @{ $json->{DailyForecasts} } ) {
        $results->appendFromValues(
            source        => 'accuweather',
            latitude      => $lat,
            longitude     => $lon,
            time          => $period->{EpochDate},
            temperature   => $period->{Temperature}{Maximum}{Value},
            windSpeed     => $period->{Day}{Wind}{Speed}{Value},
            windDirection => $period->{Day}{Wind}{Direction}{English},
            precipitation => $period->{Day}{PrecipitationProbability},
        );
    }

    setRedisTtl( $cacheKey, $results->toJson() );
    return $results;
}

1;
