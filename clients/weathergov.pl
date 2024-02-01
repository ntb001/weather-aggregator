use strict;
use warnings;

use Date::Parse;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'models/forecast.pl';
require 'clients/httpclient.pl';

# https://www.weather.gov/documentation/services-web-api#/default/gridpoint_forecast
sub get_weather_gov {
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
        if ( !$precip ) { $precip = 0 }
        my $wind = $period->{windSpeed};
        $wind =~ /([\d+] to )?(\d+) mph/;
        my $windInt = $2;
        my $entry   = Forecast->new(
            'weather.gov', $lat, $lon,
            str2time( $period->{startTime} ),
            $period->{temperature},
            $windInt, $period->{windDirection}, $precip,
        );
        push( @results, $entry );
    }
    return @results;
}

1;
