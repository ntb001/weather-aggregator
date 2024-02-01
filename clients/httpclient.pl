use strict;
use warnings;

use URI;
use URI::QueryParam;
use LWP::UserAgent ();
use JSON;

package HttpClient;

sub new {
    my $class = shift;
    my $self  = {
        _url       => URI->new(shift),
        _userAgent => 'ntb001-weatheraggregator/1.0',
        _accept    => 'application/json',
    };
    bless $self, $class;
    return $self;
}

sub setUrl {
    my ( $self, $url ) = @_;
    $self->{_url} = URI->new($url);
}

sub addQueryParam {
    my ( $self, $key, $value ) = @_;
    $self->{_url}->query_param_append( $key, $value );
}

sub setAccept {
    my ( $self, $value ) = @_;
    $self->{_accept} = $value;
}

sub setAgent {
    my ( $self, $value ) = @_;
    $self->{_userAgent} = $value;
}

sub getJson {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new();
    $ua->default_header( 'Accept-Encoding' => $self->{_accept} );
    $ua->agent( $self->{_userAgent} );
    my $response = $ua->get( $self->{_url}->as_string );
    $response->is_success
      or die $response->status_line . " for " . $self->{_url}->host;
    my $body = $response->decoded_content;
    my $json = JSON::decode_json($body);
    return $json;
}

1;
