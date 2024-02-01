use strict;
use warnings;

use Date::Parse;
use Future::AsyncAwait;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'models/forecast.pl';
require 'clients/httpclient.pl';

# https://www.weather.gov/documentation/services-web-api#/default/gridpoint_forecast
async sub getWeatherGov {
    my ( $lat, $lon ) = @_;

    # translate lat,lon into Gridpoint
    my $client = HttpClient->new("https://api.weather.gov/points/$lat,$lon");
    $client->setAgent('application/geo+json');
    my $json = $client->getJson();

    # get forecast
    my $url = $json->{properties}{forecast};
    $client->setUrl($url);
    $json = $client->getJson();

    my @results = ();
    foreach my $period ( @{ $json->{properties}->{periods} } ) {
        my $precip = $period->{propabilityOfPrecipitation}{value};
        $precip = 0 unless $precip;
        my $wind = $period->{windSpeed};
        $wind =~ /([\d+] to )?(\d+) mph/;
        my $windInt = $2;
        my $entry   = Forecast->new(
            source        => 'weather.gov',
            latitude      => $lat,
            longitude     => $lon,
            time          => str2time( $period->{startTime} ),
            temperature   => $period->{temperature},
            windSpeed     => $windInt,
            windDirection => $period->{windDirection},
            precipitation => $precip,
        );
        push( @results, $entry );
    }
    return @results;
}

1;
