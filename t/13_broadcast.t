use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/lib';
use t::Util;

use JSON::XS;
use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

my $builder = LINE::Bot::API::Builder::SendMessage->new
    ->add_text( text => 'one' )
    ->add_text( text => 'two' );

send_request {
    my $res = $bot->broadcast($builder->build);
    ok $res->is_success;
    is $res->http_status, 200;
} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://api.line.me/v2/bot/message/broadcast';

    my $data = decode_json $args{content};
    is scalar(@{ $data->{messages} }), 2;
    {
        my $message = $data->{messages}[0];
        is $message->{type}, 'text';
        is $message->{text}, 'one';
    }
    {
        my $message = $data->{messages}[1];
        is $message->{type}, 'text';
        is $message->{text}, 'two';
    }

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{};
};

done_testing;
