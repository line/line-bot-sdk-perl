use strict;
use warnings;
use lib 'lib';

use Plack::Request;

use LINE::Bot::API;
use LINE::Bot::API::Builder::SendMessage;

my $channel_secret         = $ENV{CHANNEL_SECRET};
my $channel_access_token   = $ENV{CHANNEL_ACCESS_TOKEN};
my $messaging_api_endpoint = $ENV{MESSAGING_API_ENDPOINT};
my $callback_url           = $ENV{CALLBACK_URL} // '/perl/callback';

my $bot = LINE::Bot::API->new(
    channel_secret         => $channel_secret,
    channel_access_token   => $channel_access_token,
    messaging_api_endpoint => $messaging_api_endpoint,
);

sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    unless ($req->method eq 'POST' && $req->path eq $callback_url) {
        return [200, [], ['Not Found']];
    }

    unless ($bot->validate_signature($req->content, $req->header('X-Line-Signature'))) {
        return [200, [], ['bad request']];
    }

    my $events = $bot->parse_events_from_json($req->content);
    for my $event (@{ $events }) {
        my $messages = LINE::Bot::API::Builder::SendMessage->new;

        if ($event->is_message_event) {
            my $from_id;
            if ($event->is_user_event) {
                $from_id = $event->user_id;
            } elsif ($event->is_group_event) {
                $from_id = $event->group_id;
            } elsif ($event->is_room_event) {
                $from_id = $event->room_id;
            }
            warn sprintf 'message_id=%s, type=%s(%s), reply_token=%s, timestamp=%s', $event->message_id, $event->type, $from_id, $event->reply_token, $event->timestamp;

            if ($event->is_text_message) {
                if ($event->text eq 'me' && $event->is_user_event) {
                    my $profile = $bot->get_profile($event->user_id);

                    $messages->add_text(
                        text   => sprintf('Hello! %s san! Your status message is %s', $profile->display_name, ($profile->status_message // 'null')),
                    )->add_sticker(
                        package_id => '1',
                        sticker_id => int(rand(10))+1 + '',
                    );

                } else {
                    $messages->add_text( text => $event->text );
                }
            } elsif ($event->is_image_message || $event->is_video_message) {
                my $size = do {
                    my $res = $bot->get_message_content($event->message_id);
                    $res->is_success ? (-s $res->fh) : '-';
                };

                my $type = $event->is_image_message ? 'image' : 'video';
                $messages->add_text( text => sprintf("Thank you for sending a %s.\nOriginal file size: %s", $type, $size) );
            } elsif ($event->is_audio_message) {
                $messages->add_text( text => 'Thank you for sending a audio.' );
            } elsif ($event->is_location_message) {
                $messages->add_location(
                    title     => $event->title,
                    address   => $event->address,
                    latitude  => $event->latitude,
                    longitude => $event->longitude,
                );
            } elsif ($event->is_sticker_message) {
                $messages->add_sticker(
                    sticker_id => $event->sticker_id,
                    package_id => $event->package_id,
                );
            }
        } elsif ($event->is_follow_event) {
            $messages->add_text( text => 'Thank you for adding me to your contact list!' );
        } elsif ($event->is_unfollow_event) {
            warn 'unfollow_event';
            next;
        } elsif ($event->is_join_event) {
            my $type = $event->is_group_event ? 'group' : 'room';
            $messages->add_text( text => sprintf('Thank you for adding me to this %s!', $type) );
        } elsif ($event->is_leave_event) {
            warn 'leave_event';
            next;
        } elsif ($event->is_postback_event) {
            $messages->add_text( text => sprintf('postback_data=%s', $event->postback_data) );
        } elsif ($event->is_beacon_detection_event) {
            $messages->add_text( text => sprintf('beacon_hwid=%s beacon_type=%s', $event->beacon_hwid, $event->beacon_type) );
        }

        my $res = $bot->reply_message($event->reply_token, $messages->build);

        # error handling
        unless ($res->is_success) {
            warn $res->message;
            for my $detail (@{ $res->details // []}) {
                if ($detail && ref($detail) eq 'HASH') {
                    warn "    detail: " . $detail->{message};
                }
            }
        }
    }

    return [200, [], ["OK"]];
};

__END__

=head1 NAME

echo.psgi - example echo bot

=head1 SYNOPSIS

    $ export CHANNEL_SECRET=YOUR CHANNEL SECRET
    $ export CHANNEL_ACCESS_TOKEN=YOUR CHANNEL ACCESS TOKEN
    $ plackup eg/echo.psgi

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=cut
