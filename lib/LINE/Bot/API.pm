package LINE::Bot::API;
use strict;
use warnings;
our $VERSION = '0.04';

use Carp 'croak';
use JSON::XS;
use URI;

use LINE::Bot::API::Builder::SendMessage;
use LINE::Bot::API::Client;
use LINE::Bot::API::Event;

sub new {
    my($class, %args) = @_;

    my $client = LINE::Bot::API::Client->new(%args);

    bless {
        client               => $client,
        channel_id           => $args{channel_id},
        channel_secret       => $args{channel_secret},
        channel_mid          => $args{channel_mid},
        channel_access_token => $args{channel_access_token},
        event_api_endpoint   => $args{event_api_endpoint} // 'https://trialbot-api.line.me/v1/events',
        bot_api_endpoint     => $args{bot_api_endpoint}   // 'https://api.line.me/v2/bot/',
    }, $class;
}

# for v2
sub reply_message {
    my($self, $reply_token, $messages) = @_;

    $self->{client}->post(
        $self->{bot_api_endpoint} . 'message/reply',
        +{
            replyToken => $reply_token,
            messages   => $messages,
        }
    );
}

sub push_message {
    my($self, $to_mid, $messages) = @_;

    $self->{client}->post(
        $self->{bot_api_endpoint} . 'message/push',
        +{
            to       => $to_mid,
            messages => $messages,
        }
    );
}

sub get_content {
    my($self, $message_id, %options) = @_;
    $self->{client}->contents_download(
        $self->{bot_api_endpoint} . "message/$message_id/content",
        %options
    );
}

sub get_profile {
    my($self, $user_id) = @_;
    $self->{client}->get($self->{bot_api_endpoint} . "profile/$user_id");
}

sub leave_room {
    my($self, $room_id) = @_;
    $self->{client}->post($self->{bot_api_endpoint} . "room/$room_id/leave", +{});
}

sub leave_group {
    my($self, $group_id) = @_;
    $self->{client}->post($self->{bot_api_endpoint} . "group/$group_id/leave", +{});
}

sub validate_signature {
    my($self, $json, $signature) = @_;
    LINE::Bot::API::Event->validate_signature($json, $self->{channel_secret}, $signature);
}

sub parse_events_from_json {
    my($self, $json) = @_;
    LINE::Bot::API::Event->parse_events_json($json);
}

1;
__END__

=head1 NAME

LINE::Bot::API - SDK of the LINE BOT API Trial for Perl

=for html <a href="https://travis-ci.org/line/line-bot-sdk-perl"><img src="https://travis-ci.org/line/line-bot-sdk-perl.svg?branch=master"></a>

=head1 SYNOPSIS

    # in the synopsis.psgi
    use strict;
    use warnings;
    use LINE::Bot::API;
    use Plack::Request;

    my $bot = LINE::Bot::API->new(
        channel_id     => 'YOUR LINE BOT Channel ID',
        channel_secret => 'YOUR LINE BOT Channel Secret',
        channel_mid    => 'YOUR LINE BOT MID',
    );

    sub {
        my $req = Plack::Request->new(shift);

        unless ($req->method eq 'POST' && $req->path eq '/callback') {
            return [404, [], ['Not Found']];
        }

        unless ($bot->validate_signature($req->content, $req->header('X-LINE-ChannelSignature'))) {
            return [470, [], ['failed to validate signature']];
        }

        my $receives = $bot->create_receives_from_json($req->content);
        for my $receive (@{ $receives }) {
            next unless $receive->is_message && $receive->is_text;

            my $res = $bot->send_text(
                to_mid => $receive->from_mid,
                text   => $receive->text,
            );
        }

        return [200, [], ["OK"]];
    };

=head1 DESCRIPTION

LINE::Bot::API is a client library to easily use the LINE BOT API.
You can create a bot which will run on the LINE App by registering your bot account.
Your B<BOT API Trial> account can be created from L<LINE BUSINESS CENTER|https://business.line.me/>.

You can find the B<Channel ID>, B<Channel Secret> and B<MID> on the Basic information page at L<LINE developers|https://developers.line.me/>.

Please use this POD and LINE developers site's online documentation to enjoy your bot development work!

=head1 METHODS

=head2 new()

Create a new LINE::Bot::API instance.

    my $bot = LINE::Bot::API->new(
        channel_id     => 'YOUR LINE BOT Channel ID',
        channel_secret => 'YOUR LINE BOT Channel Secret',
        channel_mid    => 'YOUR LINE BOT MID',
    );

=head2 Sending messages

The C<to_mid> parameter for the I<Sending message API>.

    $bot->send_text(
        to_mid = $mid,
    );

When you use a SCALAR value in the C<to_mid>, this method sends message to one person.
Although if you use ARRAY ref in the C<to_mid>, this sends message to all mids in the ARRAY.

    $bot->send_text(
        to_mid = [ $mid1, $mid2, $mid3, ... ],
    );

See also a online documentation.
L<https://developers.line.me/bot-api/api-reference#sending_message>

=head3 send_text()

Send a text message to the mids.

    my $res = $bot->send_text(
        to_mid => $mid,
        text   => 'Closing the distance',
    );

=head3 send_image()

Send a image file to the mids.

    my $res = $bot->send_image(
        to_mid      => $mid,
        image_url   => 'http://example.com/image.jpg',         # originalContentUrl
        preview_url => 'http://example.com/image_preview.jpg', # previewImageUrl
    );

=head3 send_video()

Send a video file to the mids.

    my $res = $bot->send_video(
        to_mid      => $mid,
        video_url   => 'http://example.com/video.mp4',         # originalContentUrl
        preview_url => 'http://example.com/video_preview.jpg', # previewImageUrl
    );

=head3 send_audio()

Send a audio file to the mids.

    my $res = $bot->send_audio(
        to_mid    => $mid,
        audio_url => 'http://example.com/image.m4a', # originalContentUrl
        duration  => 3601,                           # contentMetadata.AUDLEN
    );

=head3 send_location()

Send a location data to the mids.

    my $res = $bot->send_location(
        to_mid    => $mid,
        text      => 'LINE Corporation.',
        address   => 'Hikarie  Shibuya-ku Tokyo 151-0002', # location.address
        latitude  => '35.6591',                            # location.latitude
        longitude => '139.7040',                           # location.longitude
    );

=head3 send_sticker()

Send a sticker to the mids.

See the online documentation to find which sticker's you can send.
L<https://developers.line.me/bot-api/api-reference#sending_message_sticker>

    my $res = $bot->send_sticker(
        to_mid   => $mid,
        stkid    => 1,    # contentMetadata.STKID
        stkpkgid => 2,    # contentMetadata.STKPKGID
        stkver   => 3,    # contentMetadata.STKVER
    );

=head2 Sending rich messages

The C<rich_message> method allows you to use the I<Sending rich messages API>.

See also a online documentation.
L<https://developers.line.me/bot-api/api-reference#sending_rich_content_message>

    my $res = $bot->rich_message(
        height => 1040,
    )->set_action(
        MANGA => (
            text     => 'manga',
            link_uri => 'https://store.line.me/family/manga/en',
        ),
    )->add_listener(
        action => 'MANGA',
        x      => 0,
        y      => 0,
        width  => 520,
        height => 520,
    )->set_action(
        MUSIC => (
            text     => 'misic',
            link_uri => 'https://store.line.me/family/music/en',
        ),
    )->add_listener(
        action => 'MUSIC',
        x      => 520,
        y      => 0,
        width  => 520,
        height => 520,
    )->set_action(
        PLAY => (
            text     => 'play',
            link_uri => 'https://store.line.me/family/play/en',
        ),
    )->add_listener(
        action => 'PLAY',
        x      => 0,
        y      => 520,
        width  => 520,
        height => 520,
    )->set_action(
        FORTUNE => (
            text     => 'fortune',
            link_uri => 'https://store.line.me/family/uranai/en',
        ),
    )->add_listener(
        action => 'FORTUNE',
        x      => 520,
        y      => 520,
        width  => 520,
        height => 520,
    )->send_message(
        to_mid    => $mid,
        image_url => 'https://example.com/rich-image/foo', # see also https://developers.line.me/bot-api/api-reference#sending_rich_content_message_prerequisite
        alt_text  => 'This is a alt text.',
    );

=head2 Sending multiple messages

The C<multiple_message> method allows you to use the I<Sending multiple messages API>.

See also a online documentation.
L<https://developers.line.me/bot-api/api-reference#sending_multiple_messages>

    my $res = $bot->multiple_message(
    )->add_text(
        text        => 'hi!',
    )->add_image(
        image_url   => 'http://example.com/image.jpg',
        preview_url => 'http://example.com/image_preview.jpg',
    )->add_video(
        video_url   => 'http://example.com/video.mp4',
        preview_url => 'http://example.com/video_preview.jpg',
    )->add_audio(
        audio_url   => 'http://example.com/image.m4a',
        duration    => 3601,
    )->add_location(
        text        => 'LINE Corporation.',
        address     => 'Hikarie Shibuya-ku Tokyo 151-0002',
        latitude    => '35.6591',
        longitude   => '139.7040',
    )->add_sticker(
        stkid       => 1,
        stkpkgid    => 2,
        stkver      => 3,
    )->send_messages(
        to_mid           => $mid,
        message_notified => 0,     # messageNotified
    );

## Receiving messages/operation

The following utility methods allow you to easily process messages sent from the BOT API platform via a Callback URL.

=head3 validate_signature()

    my $req = Plack::Request->new( ... );
    unless ($bot->validate_signature($req->content, $req->header('X-LINE-ChannelSignature'))) {
        die 'failed to signature validation';
    }

=head3 create_receives_from_json()

    my $req = Plack::Request->new( ... );
    my $receives = $bot->create_receives_from_json($req->content);

See also L<LINE::Bot::Receive>.

=head2 Getting message content

You can retreive the binary contents (image files and video files) which was sent from the user to your bot's account.

    my $receives = $bot->create_receives_from_json($req->content);
    for my $receive (@{ $receives }) {
        next unless $receive->is_message && ($receive->is_image || $receive->is_video);
        if ($receive->is_image) {
            my($temp) = $bot->get_message_content($receive->content_id);
            my $original_image = $temp->filename;
        } elsif ($receive->is_video) {
            my($temp) = $bot->get_message_content($receive->content_id);
            my $original_video = $temp->filename;
        }
        my($temp) = $bot->get_preview_message_content($receive->content_id);
        my $preview_image = $temp->filename;
    }

See also a online documentation.
L<https://developers.line.me/bot-api/api-reference#getting_message_content>

=head3 get_message_content()

Get the original file which was sent by user.

=head3 get_preview_message_content()

Get the preview image file which was sent by user.

=head2 Getting user profile information

You can retrieve the user profile information by specifying the mid.

See also a online document.
L<https://developers.line.me/bot-api/api-reference#getting_user_profile_information>

    my $res = $bot->get_user_profile(@mids);
    say $res->{contacts}[0]{displayName};
    say $res->{contacts}[0]{mid};
    say $res->{contacts}[0]{pictureUrl};
    say $res->{contacts}[0]{statusMessage};

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=head1 SEE ALSO

L<LINE::Bot::API::Receive>,
L<https://business.line.me/>, L<https://developers.line.me/bot-api/overview>, L<https://developers.line.me/bot-api/getting-started-with-bot-api-trial>

=cut
