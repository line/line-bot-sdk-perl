package t::Util;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw(
    send_request send_get_content_request receive_request
);

use JSON::XS;
use Furl::HTTP;
use Furl::Response;

sub send_request (&@) {
    my($code, $mock) = @_;
    no warnings 'redefine';
    local *Furl::HTTP::request = sub {
        shift;
        my @ret = $mock->(@_);

        my ($http_status, $headers, $body);
        if (@ret == 1) {
            $body = $ret[0];
        } elsif (@ret == 2) {
            ($http_status, $body) = @ret;
        } elsif (@ret == 3) {
            ($http_status, $headers, $body) = @ret;
        }

        $http_status //= delete $body->{http_status} // 200;
        $headers //= [];

        my $json = encode_json $body;
        return ('0', $http_status, 'OK', [
            @$headers,
            'X-Line-Request-Id' => 'dummy_id',
            'Content-Type'      => 'application/json; charset=UTF-8',
            'Content-Length'    => length($json),
        ], $json);
    };
    $code->();
}
sub send_get_content_request (&@) {
    my($code, $mock) = @_;
    no warnings 'redefine';
    local *Furl::HTTP::request = sub {
        shift;
        my $ret = $mock->(@_);
        my $http_status = 200;
        return ('0', $http_status, 'OK', [
            'X-Line-Request-Id' => 'dummy_id',
            'Content-Type'      => 'image/jpeg',
            'Content-Length'    => length($ret),
        ], $ret);
    };
    $code->();
}
sub receive_request (&) { shift }

1;
