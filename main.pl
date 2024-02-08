#!/usr/bin/env perl

use strict;
use warnings;

use Try::Tiny;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'clients/openstreetmap.pl';
require 'clients/accuweather.pl';
require 'clients/weatherapi.pl';
require 'clients/weathergov.pl';
require 'models/forecastlist.pl';

sub getForecasts {
    my ($address) = @_;
    my ( $lat, $lon ) = addressToCoordinates($address);

    my $weathergovFuture  = getWeatherGov( $lat, $lon );
    my $accuweatherFuture = getAccuWeather( $lat, $lon );
    my $weatherapiFuture  = getWeatherApi( $lat, $lon );
    my $weathergov        = ForecastList->new();
    try {
        $weathergov = $weathergovFuture->get;
    }
    catch {
        warn "weather.gov failed: $_";
    };
    my $accuweather = ForecastList->new();
    try {
        $accuweather = $accuweatherFuture->get;
    }
    catch {
        warn "AccuWeather failed: $_";
    };
    my $weatherapi = ForecastList->new();
    try {
        $weatherapi = $weatherapiFuture->get;
    }
    catch {
        warn "WeatherApi failed: $_";
    };
    my $results = ForecastList->new();
    $results->merge($weathergov);
    $results->merge($accuweather);
    $results->merge($weatherapi);
    return $results;
}

# demo
print('Enter a location (CITY, ST): ');
my $location = <>;
chomp($location);
my $results = getForecasts($location);
$results->toString();
