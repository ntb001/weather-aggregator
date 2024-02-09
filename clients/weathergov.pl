use strict;
use warnings;

use Date::Parse;
use Future::AsyncAwait;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'clients/cacheclient.pl';
require 'clients/httpclient.pl';
require 'models/forecastlist.pl';

sub _getGridpoint {
    my ( $lat, $lon ) = @_;

    # try cache
    my $cacheKey = "weathergov/gridpoint/$lat,$lon";
    my $url      = cacheGet($cacheKey);
    return $url if $url;

    # translate lat,lon into Gridpoint
    my $client = HttpClient->new("https://api.weather.gov/points/$lat,$lon");
    $client->setAgent('application/geo+json');
    my $json = $client->getJson;
    $url = $json->{properties}{forecast};

    cacheSet( $cacheKey, $url );
    return $url;
}

# https://www.weather.gov/documentation/services-web-api#/default/gridpoint_forecast
async sub getWeatherGov {
    my ( $lat, $lon ) = @_;
    my $url = _getGridpoint( $lat, $lon );

    # try cache
    my $json = cacheGet($url);
    return ForecastList->new->fromJson($json) if $json;

    # get forecast
    my $client = HttpClient->new($url);
    $client->setAgent('application/geo+json');
    $json = $client->getJson();

    my $results = ForecastList->new;
    foreach my $period ( @{ $json->{properties}{periods} } ) {
        my $precip = $period->{propabilityOfPrecipitation}{value};
        $precip = 0 unless $precip;
        my $wind = $period->{windSpeed};
        $wind =~ /([\d+] to )?(\d+) mph/;
        my $windInt = $2;
        $results->appendFromValues(
            source        => 'weather.gov',
            latitude      => $lat,
            longitude     => $lon,
            time          => str2time( $period->{startTime} ),
            temperature   => $period->{temperature},
            windSpeed     => $windInt,
            windDirection => $period->{windDirection},
            precipitation => $precip,
        );
    }

    cacheSetTtl( $url, $results->toJson );
    return $results;
}

1;
