#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'clients/openstreetmap.pl';
require 'clients/accuweather.pl';
require 'clients/weatherapi.pl';
require 'clients/weathergov.pl';

sub getForecasts {
    my ($address) = @_;
    my ( $lat, $lon ) = addressToCoordinates($address);

    my @weathergov  = getWeatherGov( $lat, $lon );
    my @accuweather = getAccuweather( $lat, $lon );
    my @weatherapi  = getWeatherapi( $lat, $lon );
    my @results     = ( @weathergov, @accuweather, @weatherapi, );
    my @sorted      = sort { $a->{time} cmp $b->{time} } @results;
    return @sorted;
}

# demo
my @results = getForecasts('Fishers Island, NY');
foreach my $result (@results) {
    print( $result->toString() . '\n' );
}
