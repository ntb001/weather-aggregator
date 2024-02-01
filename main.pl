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

sub getForecasts {
    my ($address) = @_;
    my ( $lat, $lon ) = addressToCoordinates($address);

    my $weathergovFuture  = getWeatherGov( $lat, $lon );
    my $accuweatherFuture = getAccuWeather( $lat, $lon );
    my $weatherapiFuture  = getWeatherApi( $lat, $lon );
    my @weathergov        = ();
    try {
        @weathergov = $weathergovFuture->get;
    }
    catch {
        warn "weather.gov failed: $_";
    };
    my @accuweather = ();
    try {
        @accuweather = $accuweatherFuture->get;
    }
    catch {
        warn "AccuWeather failed: $_";
    };
    my @weatherapi = ();
    try {
        @weatherapi = $weatherapiFuture->get;
    }
    catch {
        warn "WeatherApi failed: $_";
    };
    my @results = ( @weathergov, @accuweather, @weatherapi, );
    my @sorted  = sort { $a->{time} cmp $b->{time} } @results;
    return @sorted;
}

# demo
my @results = getForecasts('Fishers Island, NY');
foreach my $result (@results) {
    print( $result->toString() . "\n" );
}
