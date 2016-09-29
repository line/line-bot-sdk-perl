use strict;
use warnings;
use lib 'lib';

use LINE::Bot::API;

use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;
use LINE::Bot::API::Builder::ImagemapMessage;
use LINE::Bot::API::Builder::TemplateMessage;

my $channel_secret         = $ENV{CHANNEL_SECRET};
my $channel_access_token   = $ENV{CHANNEL_ACCESS_TOKEN};
my $messaging_api_endpoint = $ENV{MESSAGING_API_ENDPOINT};

my $imagemap_image_url = $ENV{IMAGEMAP_IMAGE_URL};
my $template_image_url = $ENV{TEMPLATE_IMAGE_URL};

my($to_id, $text) = @ARGV;

my $bot = LINE::Bot::API->new(
    channel_secret         => $channel_secret,
    channel_access_token   => $channel_access_token,
    messaging_api_endpoint => $messaging_api_endpoint,
);

my $messages = LINE::Bot::API::Builder::SendMessage->new->add_text( text => $text );

# Imagemap Message
my $imagemap = LINE::Bot::API::Builder::ImagemapMessage->new(
    base_url    => $imagemap_image_url,
    alt_text    => 'altText',
    base_width  => 1040,
    base_height => 1040,
)->add_uri_action(
    uri         => 'http://example.com/',
    area_x      => 0,
    area_y      => 0,
    area_width  => 1040,
    area_height => 520,
)->add_message_action(
    text        => 'message',
    area_x      => 0,
    area_y      => 520,
    area_width  => 1040,
    area_height => 520,
);
$messages->add_imagemap($imagemap->build);


# Template Message
my $buttons = LINE::Bot::API::Builder::TemplateMessage->new_buttons(
    alt_text  => 'altText',
    image_url => $template_image_url,
    title     => 'buttons',
    text      => 'description',
)->add_postback_action(
    label => 'postback',
    data  => 'postback data',
    text  => 'postback message',
)->add_message_action(
    label => 'message',
    text  => 'message',
)->add_uri_action(
    label => 'uri',
    uri   => 'http://example.com/',
)->add_message_action(
    label => 'message2',
    text  => 'message2',
);
$messages->add_template($buttons->build);

my $confirm = LINE::Bot::API::Builder::TemplateMessage->new_confirm(
    alt_text => 'altText',
    text     => 'confirm',
)->add_postback_action(
    label => 'postback',
    data  => 'postback data',
    text  => 'postback message',
)->add_message_action(
    label => 'message',
    text  => 'message',
)->add_uri_action(
    label => 'uri',
    uri   => 'http://example.com/',
);
$messages->add_template($confirm->build);

my $carousel = LINE::Bot::API::Builder::TemplateMessage->new_carousel(
    alt_text => 'altText',
);
for my $i (1..5) {
    my $column = LINE::Bot::API::Builder::TemplateMessage::Column->new(
        image_url => $template_image_url,
        title     => "carousel $i",
        text      => "description $i",
    )->add_postback_action(
        label => 'postback',
        data  => 'postback data',
        text  => 'postback message',
    )->add_message_action(
        label => 'message',
        text  => 'message',
    )->add_uri_action(
        label => 'uri',
        uri   => 'http://example.com/',
    );
    $carousel->add_column($column->build);
}
$messages->add_template($carousel->build);

$bot->push_message($to_id, $messages->build);


__END__

=head1 NAME

push_imagemap-template.pl - example script for push message (imagemap/template)

=head1 SYNOPSIS

    $ export CHANNEL_SECRET=YOUR CHANNEL SECRET
    $ export CHANNEL_ACCESS_TOKEN=YOUR CHANNEL ACCESS TOKEN
    $ export IMAGEMAP_IMAGE_URL=https://example.com/images/cats
    $ export TEMPLATE_IMAGE_URL=https://example.com/images/template_image.jpg
    $ perl push_imagemap-template.pl <TO_ID> <SEND_TEXT_MESSAGE>

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=cut
