#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'clients/openstreetmap.pl';
require 'clients/accuweather.pl';
require 'clients/weatherapi.pl';
require 'clients/weathergov.pl';

sub get_forecasts {
    my ($address) = @_;
    my ( $lat, $lon ) = address_to_coordinates($address);

    my @weathergov  = get_weather_gov( $lat, $lon );
    my @accuweather = get_accuweather( $lat, $lon );
    my @weatherapi  = get_weatherapi( $lat, $lon );
    my @results     = ( @weathergov, @accuweather, @weatherapi, );
    my @sorted      = sort { $a->{time} cmp $b->{time} } @results;
    return @sorted;
}

# demo
my @results = get_forecasts('Fishers Island, NY');
foreach my $result (@results) {
    print( $result->toString() . '\n' );
}
