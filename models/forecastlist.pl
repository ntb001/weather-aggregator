use strict;
use warnings;

use JSON;

use FindBin qw( $RealBin );
use lib $RealBin;

require 'models/forecast.pl';

package ForecastList;

sub new {
    my $class = shift;
    my @array = ();
    my $self  = { data => \@array, };
    bless $self, $class;
    return $self;
}

sub getArray {
    my ($self) = @_;
    return $self->{data};
}

sub append {
    my ( $self, $forecast ) = @_;
    push( @{ $self->{data} }, $forecast );
    return $self;
}

sub appendFromValues {
    my ( $self, %args ) = @_;
    my $forecast = Forecast->new(
        source        => $args{source},
        latitude      => $args{latitude},
        longitude     => $args{longitude},
        time          => $args{time},
        temperature   => $args{temperature},
        windSpeed     => $args{windSpeed},
        windDirection => $args{windDirection},
        precipitation => $args{precipitation},
    );
    $self->append($forecast);
    return $self;
}

sub merge {
    my ( $self, $other ) = @_;
    push( @{ $self->{data} }, @{ $other->{data} } );
    return $self;
}

sub sort {
    my ($self) = @_;
    my @array = sort { $a->{time} <=> $b->{time} } @{ $self->{data} };
    $self->{data} = \@array;
    return $self;
}

sub toString {
    my ($self) = @_;
    $self->sort();
    foreach my $forecast ( @{ $self->{data} } ) {
        print( $forecast->toString() . "\n" );
    }
}

sub toJson {
    my ($self) = @_;
    my $json = JSON->new->convert_blessed( [1] );
    return $json->encode( $self->{data} );
}

sub fromJson {
    my ( $self, $raw ) = @_;
    my $json = JSON->new->decode($raw);
    foreach my $entry ( @{$json} ) {
        $self->appendFromValues(
            source        => $entry->{source},
            latitude      => $entry->{latitude},
            longitude     => $entry->{longitude},
            time          => $entry->{time},
            temperature   => $entry->{temperature},
            windSpeed     => $entry->{windSpeed},
            windDirection => $entry->{windDirection},
            precipitation => $entry->{precipitation},
        );
    }
    return $self;
}

1;
