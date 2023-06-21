use Test2::V0;
use lib 't/lib';
use t::Util;

use LINE::Bot::API;

use JSON::XS;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

subtest "validate reply message objects" => sub {
    send_request {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_text( text => 'hello!' );
        $builder->add_text( text => 'world!' );

        my $res = $bot->validate_reply_message_objects($builder->build);

        isa_ok $res, 'LINE::Bot::API::Response::Common';
        is $res->is_success, T();
        is $res->http_status, 200;

    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/message/validate/reply';

        my $data = decode_json $args{content};
        is scalar(@{ $data->{messages} }), 2;
        my $message1 = $data->{messages}[0];
        is $message1->{type}, 'text';
        is $message1->{text}, 'hello!';
        my $message2 = $data->{messages}[1];
        is $message2->{type}, 'text';
        is $message2->{text}, 'world!';

        +{};
    };
};

subtest "validate push message objects" => sub {
    send_request {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_text( text => 'hello!' );
        $builder->add_text( text => 'world!' );

        my $res = $bot->validate_push_message_objects($builder->build);

        isa_ok $res, 'LINE::Bot::API::Response::Common';
        is $res->is_success, T();
        is $res->http_status, 200;

    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/message/validate/push';

        my $data = decode_json $args{content};
        is scalar(@{ $data->{messages} }), 2;
        my $message1 = $data->{messages}[0];
        is $message1->{type}, 'text';
        is $message1->{text}, 'hello!';
        my $message2 = $data->{messages}[1];
        is $message2->{type}, 'text';
        is $message2->{text}, 'world!';

        +{};
    };
};

subtest "validate multicast message objects" => sub {
    send_request {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_text( text => 'hello!' );
        $builder->add_text( text => 'world!' );

        my $res = $bot->validate_multicast_message_objects($builder->build);

        isa_ok $res, 'LINE::Bot::API::Response::Common';
        is $res->is_success, T();
        is $res->http_status, 200;

    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/message/validate/multicast';

        my $data = decode_json $args{content};
        is scalar(@{ $data->{messages} }), 2;
        my $message1 = $data->{messages}[0];
        is $message1->{type}, 'text';
        is $message1->{text}, 'hello!';
        my $message2 = $data->{messages}[1];
        is $message2->{type}, 'text';
        is $message2->{text}, 'world!';

        +{};
    };
};

subtest "validate narrowcast message objects" => sub {
    send_request {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_text( text => 'hello!' );
        $builder->add_text( text => 'world!' );

        my $res = $bot->validate_narrowcast_message_objects($builder->build);

        isa_ok $res, 'LINE::Bot::API::Response::Common';
        is $res->is_success, T();
        is $res->http_status, 200;

    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/message/validate/narrowcast';

        my $data = decode_json $args{content};
        is scalar(@{ $data->{messages} }), 2;
        my $message1 = $data->{messages}[0];
        is $message1->{type}, 'text';
        is $message1->{text}, 'hello!';
        my $message2 = $data->{messages}[1];
        is $message2->{type}, 'text';
        is $message2->{text}, 'world!';

        +{};
    };
};

subtest "validate broadcast message objects" => sub {
    send_request {
        my $builder = LINE::Bot::API::Builder::SendMessage->new;
        $builder->add_text( text => 'hello!' );
        $builder->add_text( text => 'world!' );

        my $res = $bot->validate_broadcast_message_objects($builder->build);

        isa_ok $res, 'LINE::Bot::API::Response::Common';
        is $res->is_success, T();
        is $res->http_status, 200;

    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/message/validate/broadcast';

        my $data = decode_json $args{content};
        is scalar(@{ $data->{messages} }), 2;
        my $message1 = $data->{messages}[0];
        is $message1->{type}, 'text';
        is $message1->{text}, 'hello!';
        my $message2 = $data->{messages}[1];
        is $message2->{type}, 'text';
        is $message2->{text}, 'world!';

        +{};
    };
};

done_testing;
