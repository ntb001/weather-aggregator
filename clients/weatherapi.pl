use strict;
use warnings;

use Config::Tiny;
use Future::AsyncAwait;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'clients/cacheclient.pl';
require 'clients/httpclient.pl';
require 'models/forecastlist.pl';

my $config = Config::Tiny->read('config.ini');
die 'config.ini not found.' unless $config;

my $api_key = $config->{weatherapi}->{api};
die 'API Key for WeatherAPI.com not found in config.ini' unless $api_key;

# https://app.swaggerhub.com/apis-docs/WeatherAPI.com/WeatherAPI/1.0.2#/APIs/forecast-weather

async sub getWeatherApi {
    my ( $lat, $lon ) = @_;

    # try cache
    my $cacheKey = "weatherapi/$lat,$lon";
    my $json     = cacheGet($cacheKey);
    return ForecastList->fromJson($json) if $json;

    my $client = HttpClient->new('https://api.weatherapi.com/v1/forecast.json');
    $client->addQueryParam( 'key',  $api_key );
    $client->addQueryParam( 'q',    "$lat,$lon" );
    $client->addQueryParam( 'days', 3 );
    $json = $client->getJson;

    my $results = ForecastList->new;
    foreach my $period ( @{ $json->{forecast}{forecastday} } ) {
        my $wind_direction;
        foreach my $hour ( @{ $period->{hour} } ) {

            # get wind direction at noon
            my @time = localtime( str2time( $hour->{time} ) );
            next unless $time[2] == 12;
            $wind_direction = $hour->{wind_dir};
            last;
        }
        $results->appendFromValues(
            source        => 'weatherapi',
            latitude      => $lat,
            longitude     => $lon,
            time          => $period->{date_epoch},
            temperature   => $period->{day}{maxtemp_f},
            windSpeed     => $period->{day}{maxwind_mph},
            windDirection => $wind_direction,
            precipitation => $period->{day}{daily_chance_of_rain},
        );
    }

    cacheSetTtl( $cacheKey, $results->toJson );
    return $results;
}

1;
