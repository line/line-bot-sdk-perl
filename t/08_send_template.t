use strict;
use warnings;
use Test::More;
use t::Util;

use JSON::XS;
use LINE::Bot::API;
use LINE::Bot::API::Builder::TemplateMessage;
use LINE::Bot::API::Builder::SendMessage;

my $bot = LINE::Bot::API->new(
    channel_secret       => 'testsecret',
    channel_access_token => 'ACCESS_TOKEN',
);

my $builder = LINE::Bot::API::Builder::SendMessage->new;

# buttons
{
    my $template = LINE::Bot::API::Builder::TemplateMessage->new_buttons(
        alt_text  => 'This is buttons',
        image_url => 'http://example.com/image.jpg',
        title     => 'title',
        text      => 'description',
    )->add_postback_action(
        label => 'label',
        data  => 'postback data',
        text  => 'send text',
    )->add_message_action(
        label => 'label',
        text  => 'send text',
    )->add_uri_action (
        label => 'label',
        uri   => 'https://example.com/',
    );
    $builder->add_template($template->build);
}
# buttons
{
    my $template = LINE::Bot::API::Builder::TemplateMessage->new_confirm(
        alt_text  => 'This is confirm',
        text      => 'description',
    );
    $builder->add_template($template->build);
}
# carousel
{
    my $template = LINE::Bot::API::Builder::TemplateMessage->new_carousel(
        alt_text  => 'This is carousel',
    );

    my $column = LINE::Bot::API::Builder::TemplateMessage::Column->new(
        image_url => 'http://example.com/image.jpg',
        title     => 'title',
        text      => 'description',
    )->add_postback_action(
        label => 'label',
        data  => 'postback data',
        text  => 'send text',
    )->add_message_action(
        label => 'label',
        text  => 'send text',
    )->add_uri_action (
        label => 'label',
        uri   => 'https://example.com/',
    );
    $template->add_column($column->build);

    $builder->add_template($template->build);
}

sub run_messages {
    my $messages = shift;

    is scalar(@{ $messages }), 3;
    {
        my $message = $messages->[0];
        is $message->{type}, 'template';
        is $message->{altText}, 'This is buttons';

        my $template = $message->{template};
        is $template->{type}, 'buttons';
        is $template->{thumbnailImageUrl}, 'http://example.com/image.jpg';
        is $template->{title}, 'title';
        is $template->{text}, 'description';

        is scalar(@{ $template->{actions} }), 3;
        is_deeply $template->{actions}[0], +{
            type  => 'postback',
            label => 'label',
            data  => 'postback data',
            text  => 'send text',
        };
        is_deeply $template->{actions}[1], +{
            type  => 'message',
            label => 'label',
            text  => 'send text',
        };
        is_deeply $template->{actions}[2], +{
            type  => 'uri',
            label => 'label',
            uri   => 'https://example.com/',
        };
    }

    {
        my $message = $messages->[1];
        is $message->{type}, 'template';
        is $message->{altText}, 'This is confirm';

        my $template = $message->{template};
        is $template->{type}, 'confirm';
        is $template->{text}, 'description';

        is scalar(@{ $template->{actions} }), 0;
    }

    {
        my $message = $messages->[2];
        is $message->{type}, 'template';
        is $message->{altText}, 'This is carousel';

        my $template = $message->{template};
        is $template->{type}, 'carousel';

        is scalar(@{ $template->{columns} }), 1;
        my $column = $template->{columns}[0];
        is $column->{thumbnailImageUrl}, 'http://example.com/image.jpg';
        is $column->{title}, 'title';
        is $column->{text}, 'description';

        is scalar(@{ $column->{actions} }), 3;
        is_deeply $column->{actions}[0], +{
            type  => 'postback',
            label => 'label',
            data  => 'postback data',
            text  => 'send text',
        };
        is_deeply $column->{actions}[1], +{
            type  => 'message',
            label => 'label',
            text  => 'send text',
        };
        is_deeply $column->{actions}[2], +{
            type  => 'uri',
            label => 'label',
            uri   => 'https://example.com/',
        };
    }
}

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
    run_messages $data->{messages};

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
    run_messages $data->{messages};

    my $has_header = 0;
    my @headers = @{ $args{headers} };
    while (my($key, $value) = splice @headers, 0, 2) {
        $has_header++ if $key eq 'Authorization' && $value eq 'Bearer ACCESS_TOKEN';
    }
    is $has_header, 1;

    +{};
};

done_testing;
