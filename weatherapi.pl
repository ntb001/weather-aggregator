use strict;
use warnings;

use Config::Tiny;
use URI;
use URI::QueryParam;
use LWP::UserAgent ();
use JSON;

my $config = Config::Tiny->read('config.ini');
die 'config.ini not found.' unless $config;

my $api_key = $config->{weatherapi}{api};
die 'API Key for WeatherAPI.com not found in config.ini' unless $api_key;

# https://app.swaggerhub.com/apis-docs/WeatherAPI.com/WeatherAPI/1.0.2#/APIs/forecast-weather

sub get_weatherapi {
    my ( $lat, $lon ) = @_;

    my $url = URI->new('https://api.weatherapi.com/v1/forecast.json');
    $url->query_param_append( 'key',  $api_key );
    $url->query_param_append( 'q',    "$lat,$lon" );
    $url->query_param_append( 'days', 3 );

    my $ua = LWP::UserAgent->new();
    $ua->default_header( 'Accept-Encoding' => 'application/json' );

    my $response = $ua->get( $url->as_string );
    $response->is_success or die $response->status_line;
    my $json         = $response->decoded_content;
    my $decoded_json = decode_json($json);

    my @results = ();
    foreach my $period ( @{ $decoded_json->{forecast}{forecastday} } ) {
        my $wind_direction;
        foreach my $hour ( @{ $period->{hour} } ) {

            # get wind direction at noon
            my @time = localtime( str2time( $hour->{time} ) );
            next unless $time[2] == 12;
            $wind_direction = $hour->{wind_dir};
            last;
        }
        my %entry = (
            source         => 'weatherapi',
            latitude       => $lat,
            longitude      => $lon,
            utc_time       => $period->{date_epoch},
            temperature    => $period->{day}{maxtemp_f},
            wind_speed     => $period->{day}{maxwind_mph},
            wind_direction => $wind_direction,
            precipitation  => $period->{day}{daily_chance_of_rain},
        );
        push( @results, \%entry );
    }
    return @results;
}

1;
