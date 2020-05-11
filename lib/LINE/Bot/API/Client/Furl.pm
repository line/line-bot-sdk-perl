package LINE::Bot::API::Client::Furl;
use strict;
use warnings;

use Carp qw/ carp croak /;
use File::Temp;
use Furl::HTTP;
use Furl::Headers;
use JSON::XS;

use LINE::Bot::API;
use LINE::Bot::API::Client;

our @CARP_NOT = qw( LINE::Bot::API::Client::Furl LINE::Bot::API::Client LINE::Bot::API);
my $JSON = JSON::XS->new->utf8;

sub __decode_response_body {
    my ($response_body) = @_;

    unless ($response_body) {
        croak 'LINE Messaging API error: response body is empty.';
    }

    my ($ret, $error);
    eval {
        $ret = $JSON->decode($response_body);
        1;
    } or do {
        $error = $@;
    };

    if ($error) {
        croak 'LINE Messaging API error: ' . $error . '. response_body=' . $response_body;
    }

    return $ret;
}

sub new {
    my($class, %args) = @_;

    $args{http_client}          ||= +{};
    $args{http_client}{agent}   ||= "LINE::Bot::API/$LINE::Bot::API::VERSION";
    $args{http_client}{timeout} ||= 3;
    bless {
        channel_secret       => $args{channel_secret},
        channel_access_token => $args{channel_access_token},
        furl                 => Furl::HTTP->new(
            %{ $args{http_client} }
        ),
    }, $class;
}

sub credentials {
    my $self = shift;
    (
        'Authorization', "Bearer $self->{channel_access_token}"
    );
}

sub get {
    my($self, $url) = @_;

    my($res_minor_version, $res_status, $res_msg, $res_headers, $res_content) = $self->{furl}->get(
        $url,
        [
            $self->credentials,
        ],
    );

    my $ret = __decode_response_body($res_content);
    $ret->{http_status} = $res_status;
    $ret;
}

sub get_content {
    my($self, $url) = @_;

    my($res_minor_version, $res_status, $res_msg, $res_headers, $res_content) = $self->{furl}->get(
        $url,
        [
            $self->credentials,
        ],
    );

    $res_content;
}

sub post {
    my($self, $url, $data) = @_;

    my $json = $JSON->encode($data);
    my($res_minor_version, $res_status, $res_msg, $res_headers, $res_content) = $self->{furl}->post(
        $url,
        [
            $self->credentials,
            'Content-Type'   => 'application/json',
            'Content-Length' => length($json),
        ],
        $json,
    );

    my $ret = __decode_response_body($res_content);
    $ret->{http_status} = $res_status;
    $ret->{http_headers} = Furl::Headers->new($res_headers);
    $ret;
}

sub post_form {
    my ($self, $url, $headers, $data) = @_;

    $headers //= [];
    $data //= [];

    my($res_minor_version, $res_status, $res_msg, $res_headers, $res_content) = $self->{furl}->post(
        $url,
        [ @$headers, 'Content-Type' => 'application/x-www-form-urlencoded' ],
        $data,
    );

    my $ret = __decode_response_body($res_content);
    $ret->{http_status} = $res_status;
    $ret;
}

sub post_image {
    my ($self, $url, $headers, $filePath) = @_;

    $headers //= [];

    open my $fh, '<', $filePath
        or croak 'Failed to open file.';

    my($res_minor_version, $res_status, $res_msg, $res_headers, $res_content) = $self->{furl}->post(
        $url,
        [
            @$headers,
            $self->credentials,
        ],
        $fh,
    );

    close $fh;

    my $ret = __decode_response_body($res_content);
    $ret->{http_status} = $res_status;
    $ret;
}

sub put {
    my($self, $url, $data) = @_;

    my $json = $JSON->encode($data);
    my($res_minor_version, $res_status, $res_msg, $res_headers, $res_content) = $self->{furl}->put(
        $url,
        [
            $self->credentials,
            'Content-Type'   => 'application/json',
            'Content-Length' => length($json),
        ],
        $json,
    );

    my $ret = __decode_response_body($res_content);
    $ret->{http_status} = $res_status;
    $ret->{http_headers} = Furl::Headers->new($res_headers);
    $ret;
}

sub delete {
    my($self, $url) = @_;

    my($res_minor_version, $res_status, $res_msg, $res_headers, $res_content) = $self->{furl}->delete(
        $url,
        [
            $self->credentials,
        ],
    );

    my $ret = __decode_response_body($res_content);
    $ret->{http_status} = $res_status;
    $ret;
}

sub contents_download {
    my($self, $url, %options) = @_;

    my $fh = CORE::delete($options{fh}) || File::Temp->new(%options);

    my($res_minor_version, $res_status, $res_msg, $res_headers, $res_content) = $self->{furl}->request(
        method     => 'GET',
        url        => $url,
        write_file => $fh,
        headers    => [
            $self->credentials,
        ],
    );
    unless ($res_status eq '200') {
        carp "LINE Messaging API contents_download error: $res_status $url\n\tcontent=$res_content";
    }

    +{
        http_status => $res_status,
        fh          => $fh,
        headers     => $res_headers,
    };
}

1;
