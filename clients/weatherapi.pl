use strict;
use warnings;

use Config::Tiny;
use Future::AsyncAwait;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'models/forecast.pl';
require 'clients/httpclient.pl';

my $config = Config::Tiny->read('config.ini');
die 'config.ini not found.' unless $config;

my $api_key = $config->{weatherapi}{api};
die 'API Key for WeatherAPI.com not found in config.ini' unless $api_key;

# https://app.swaggerhub.com/apis-docs/WeatherAPI.com/WeatherAPI/1.0.2#/APIs/forecast-weather

async sub getWeatherApi {
    my ( $lat, $lon ) = @_;

    my $client = HttpClient->new('https://api.weatherapi.com/v1/forecast.json');
    $client->addQueryParam( 'key',  $api_key );
    $client->addQueryParam( 'q',    "$lat,$lon" );
    $client->addQueryParam( 'days', 3 );
    my $json = $client->getJson();

    my @results = ();
    foreach my $period ( @{ $json->{forecast}{forecastday} } ) {
        my $wind_direction;
        foreach my $hour ( @{ $period->{hour} } ) {

            # get wind direction at noon
            my @time = localtime( str2time( $hour->{time} ) );
            next unless $time[2] == 12;
            $wind_direction = $hour->{wind_dir};
            last;
        }
        my $entry = Forecast->new(
            'weatherapi',              $lat,
            $lon,                      $period->{date_epoch},
            $period->{day}{maxtemp_f}, $period->{day}{maxwind_mph},
            $wind_direction,           $period->{day}{daily_chance_of_rain},
        );
        push( @results, $entry );
    }
    return @results;
}

1;
