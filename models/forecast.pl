use DateTime;

package Forecast;

sub new {
    my $class = shift;
    my %args  = @_;
    my $self  = {
        source        => $args{source},
        latitude      => $args{latitude},
        longitude     => $args{longitude},
        time          => DateTime->from_epoch( $args{time} ),
        temperature   => $args{temperature},
        windSpeed     => $args{windSpeed},
        windDirection => $args{windDirection},
        precipitation => $args{precipitation},
    };
    bless $self, $class;
    return $self;
}

sub getTimeString {
    my ($self) = @_;
    return $self->{time}->rfc3339;
}

sub toString {
    my ($self) = @_;
    return
        "Location: $self->{latitude}, $self->{longitude}; "
      . "Date: @{[$self->getTimeString()]}; High temp: $self->{temperature}*F; "
      . "Wind: $self->{windDirection} $self->{windSpeed} mph; "
      . "Precipitation: $self->{precipitation}%; Source: $self->{source}";
}

1;
