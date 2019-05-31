package LINE::Bot::API::Event;
use strict;
use warnings;

use Carp 'carp';
our @CARP_NOT = qw( LINE::Bot::API::Event LINE::Bot::API);

use Digest::SHA 'hmac_sha256';
use JSON::XS 'decode_json';
use MIME::Base64 'decode_base64';

use LINE::Bot::API::Event::Message;
use LINE::Bot::API::Event::Follow;
use LINE::Bot::API::Event::Unfollow;
use LINE::Bot::API::Event::Join;
use LINE::Bot::API::Event::Leave;
use LINE::Bot::API::Event::MemberJoin;
use LINE::Bot::API::Event::MemberLeave;
use LINE::Bot::API::Event::Postback;
use LINE::Bot::API::Event::BeaconDetection;
use LINE::Bot::API::Event::Things;
use LINE::Bot::API::Event::AccountLink;

my %TYPE2CLASS = (
    message      => 'LINE::Bot::API::Event::Message',
    follow       => 'LINE::Bot::API::Event::Follow',
    unfollow     => 'LINE::Bot::API::Event::Unfollow',
    join         => 'LINE::Bot::API::Event::Join',
    leave        => 'LINE::Bot::API::Event::Leave',
    memberJoined => 'LINE::Bot::API::Event::MemberJoin',
    memberLeft   => 'LINE::Bot::API::Event::MemberLeave',
    postback     => 'LINE::Bot::API::Event::Postback',
    beacon       => 'LINE::Bot::API::Event::BeaconDetection',
    things       => 'LINE::Bot::API::Event::Things',
    accountLink  => 'LINE::Bot::API::Event::AccountLink',
);

sub parse_events_json {
    my($self, $json) = @_;
    my $events = [];

    my $data = decode_json $json;
    for my $event_data (@{ $data->{events} }) {
        my $type = $event_data->{type};
        my $event_class = $TYPE2CLASS{$type};
        unless ($event_class) {
            carp 'Unsupported event type: ' . $type;
        }

        my $event = $event_class->new(%{ $event_data });
        push @{ $events }, $event;
    }

    $events;
}

sub validate_signature {
    my($class, $json, $channel_secret, $signature) = @_;
    return unless $signature && $json && $channel_secret;
    my $json_signature = hmac_sha256($json, $channel_secret);
    _secure_compare(decode_base64($signature), $json_signature);
}

# Constant time string comparison for timing attacks.
sub _secure_compare {
    my($x, $y) = @_;
    return unless length $x == length $y;
    my @a = unpack 'C*', $x;
    my @b = unpack 'C*', $y;
    my $compare = 0;
    for my $i (0..(scalar(@a) - 1)) {
        $compare |= $a[$i] ^ $b[$i];
    }
    return !$compare;
}

1;
__END__

=head1 NAME

LINE::Bot::API::Event - Handler for Webhook Event Objects

=head1 SYNOPSIS

    use strict;
    use warnings;
    use LINE::Bot::API;

    my $bot = LINE::Bot::API->new(
        channel_secret       => $channel_secret,
        channel_access_token => $channel_access_token,
    );

    my $events = $bot->parse_events_from_json($json);
    for my $event (@{ $events }) {
        if ($event->is_user_event) {
            say $event->user_id;
        } elsif ($event->is_group_event) {
            say $event->group_id;
        } elsif ($event->is_room_event) {
            say $event->room_id;
        }

        if ($event->is_message_event) {
            say $event->message_id;
            say $event->reply_token;
            say $event->timestamp;

            if ($event->is_text_message) {
                say $event->text;
            } elsif ($event->is_image_message) {
                # LINE::Bot::API::Event::Message::Image has no getter method
            } elsif ($event->is_video_message) {
                # LINE::Bot::API::Event::Message::Video has no getter method
            } elsif ($event->is_audio_message) {
                # LINE::Bot::API::Event::Message::Audio has no getter method
            } elsif ($event->is_location_message) {
                say $event->title;
                say $event->address;
                say $event->latitude;
                say $event->longitude;
            } elsif ($event->is_sticker_message) {
                say $event->package_id;
                say $event->sticker_id;
            }
        } elsif ($event->is_follow_event) {
            say $event->reply_token;
        } elsif ($event->is_unfollow_event) {
            # LINE::Bot::API::Event::Unfollow has no getter method
        } elsif ($event->is_join_event) {
            say $event->reply_token;
        } elsif ($event->is_leave_event) {
            # LINE::Bot::API::Event::Leave has no getter method
        } elsif ($event->is_postback_event) {
            say $event->reply_token;

            say $event->postback_data;
        } elsif ($event->is_beacon_detection_event) {
            say $event->reply_token;

            say $event->beacon_hwid;
            say $event->beacon_type;
        } elsif ($event->is_things_event) {
            say $event->reply_token;
            say $event->things_device_id;
            say $event->things_type;
        }
    }

=head1 DESCRIPTION

LINE::Bot::API::Event is a handler to receive events from LINE Messaging API.
Allows you to easily handle operatiion messages.

Using instance method directly is not-recommended.
Please use L<parse_events_from_json($json)|LINE::Bot::API/parse_events_from_json($json)> of LINE::Bot::API instead.

See also L<webhook event object|https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects> for more about the attributes.

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=head1 SEE ALSO

L<https://developers.line.biz/>

=cut
