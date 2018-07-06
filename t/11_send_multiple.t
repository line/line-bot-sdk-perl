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
    ->add_text( text => '一' )
    ->add_text( text => '二' )
    ->add_text( text => '三' )
    ->add_text( text => '四' )
    ->add_text( text => '五' );

send_request {
    my $res = $bot->push_message('DUMMY_ID', $builder->build);
    ok $res->is_success;
    is $res->http_status, 200;
} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://api.line.me/v2/bot/message/push';

    my $data = decode_json $args{content};
    is $data->{to}, 'DUMMY_ID';
    is scalar(@{ $data->{messages} }), 5;
    {
        my $message = $data->{messages}[0];
        is $message->{type}, 'text';
        is $message->{text}, '一';
    }
    {
        my $message = $data->{messages}[1];
        is $message->{type}, 'text';
        is $message->{text}, '二';
    }
    {
        my $message = $data->{messages}[2];
        is $message->{type}, 'text';
        is $message->{text}, '三';
    }
    {
        my $message = $data->{messages}[3];
        is $message->{type}, 'text';
        is $message->{text}, '四';
    }
    {
        my $message = $data->{messages}[4];
        is $message->{type}, 'text';
        is $message->{text}, '五';
    }

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{};
};

send_request {
    my $res = $bot->reply_message('DUMMY_TOKEN', $builder->build);
    ok $res->is_success;
    is $res->http_status, 200;
} receive_request {
    my %args = @_;
    is $args{method}, 'POST';
    is $args{url},    'https://api.line.me/v2/bot/message/reply';

    my $data = decode_json $args{content};
    is $data->{replyToken}, 'DUMMY_TOKEN';
    is scalar(@{ $data->{messages} }), 5;
    {
        my $message = $data->{messages}[0];
        is $message->{type}, 'text';
        is $message->{text}, '一';
    }
    {
        my $message = $data->{messages}[1];
        is $message->{type}, 'text';
        is $message->{text}, '二';
    }
    {
        my $message = $data->{messages}[2];
        is $message->{type}, 'text';
        is $message->{text}, '三';
    }
    {
        my $message = $data->{messages}[3];
        is $message->{type}, 'text';
        is $message->{text}, '四';
    }
    {
        my $message = $data->{messages}[4];
        is $message->{type}, 'text';
        is $message->{text}, '五';
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
