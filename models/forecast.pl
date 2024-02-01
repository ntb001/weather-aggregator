use DateTime;

package Forecast;

sub new {
    my $class = shift;
    my $self  = {
        source        => shift,
        latitude      => shift,
        longitude     => shift,
        time          => DateTime->from_epoch(shift),
        temperature   => shift,
        windSpeed     => shift,
        windDirection => shift,
        precipitation => shift,
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
