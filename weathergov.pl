use strict;
use warnings;

use LWP::UserAgent ();
use JSON;
use Date::Parse;

# https://www.weather.gov/documentation/services-web-api#/default/gridpoint_forecast
sub get_weather_gov {
    my ( $lat, $lon ) = @_;
    my $ua = LWP::UserAgent->new();
    $ua->agent('ntb001-weatheraggregator/1.0');
    $ua->default_header( 'Accept-Encoding' => 'application/geo+json' );

    # translate lat,lon into Gridpoint
    my $url      = "https://api.weather.gov/points/$lat,$lon";
    my $response = $ua->get($url);
    die $response->status_line unless $response->is_success;
    my $json         = $response->decoded_content;
    my $decoded_json = decode_json($json);

    # get forecast
    $url      = $decoded_json->{properties}{forecast};
    $response = $ua->get($url);
    die $response->status_line unless $response->is_success;
    $json         = $response->decoded_content;
    $decoded_json = decode_json($json);

    my @results = ();
    foreach my $period ( @{ $decoded_json->{properties}->{periods} } ) {
        my $precip = $period->{propabilityOfPrecipitation}{value};
        if ( !$precip ) { $precip = 0 }
        my $ts    = str2time( $period->{startTime} );
        my %entry = (
            source         => 'weather.gov',
            latitude       => $lat,
            longitude      => $lon,
            utc_time       => $ts,
            temperature    => $period->{temperature},
            wind_speed     => $period->{windSpeed},
            wind_direction => $period->{windDirection},
            precipitation  => $precip,
        );
        push( @results, \%entry );
    }
    return @results;
}

1;
