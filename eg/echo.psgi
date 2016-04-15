use strict;
use warnings;
use lib 'lib';

use Plack::Request;

use LINE::Bot::API;

my $channel_id     = $ENV{CHANNEL_ID};
my $channel_secret = $ENV{CHANNEL_SECRET};
my $channel_mid    = $ENV{CHANNEL_MID};

my $bot = LINE::Bot::API->new(
    channel_id     => $channel_id,
    channel_secret => $channel_secret,
    channel_mid    => $channel_mid,
);

sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    unless ($req->method eq 'POST' && $req->path eq '/perl/callback') {
        return [404, [], ['Not Found']];
    }

    unless ($bot->signature_validation($req->content, $req->header('X-LINE-ChannelSignature'))) {
        return [500, [], ['bad request']];
    }

    my $receives = $bot->create_receives_from_json($req->content);
    for my $receive (@{ $receives }) {
        if ($receive->is_message) {
            warn sprintf 'content_id=%s, from_mid=%s, created_time=%s', $receive->content_id, $receive->from_mid, $receive->created_time;

            if ($receive->is_text) {
                if ($receive->text eq 'me') {
                    my $res = $bot->get_profile_information($receive->from_mid);
                    my $contact = $res->{contacts}[0];

                    $bot->multiple_message->add_text(
                        to_mid => $receive->from_mid,
                        text   => sprintf('Hello! %s san! Your status message is %s', $contact->{displayName}, $contact->{statusMessage}),
                    )->add_image(
                        image_url   => $contact->{pictureUrl},
                        preview_url => $contact->{pictureUrl},
                    )->add_sticker(
                        stkid       => int(rand(10))+1,
                        stkpkgid    => 1,
                        stkver      => 100,
                    )->send_messages(
                        to_mid           => $receive->from_mid,
                        message_notified => 0,
                    );
                } else {
                    $bot->send_text(
                        to_mid => $receive->from_mid,
                        text   => $receive->text,
                    );
                }
            } elsif ($receive->is_image || $receive->is_video) {
                my $size = do {
                    my($temp) = $bot->get_message_content($receive->content_id);
                    -s $temp;
                };
                my $preview_size = do {
                    my($temp) = $bot->get_message_content($receive->content_id);
                    -s $temp;
                };

                my $type = $receive->is_image ? 'image' : 'video';

                $bot->send_text(
                    to_mid => $receive->from_mid,
                    text   => sprintf("Thank you for sending a %s.\nOriginal file size: %s\nPreview file size: %s", $type, $size, $preview_size),
                );
            } elsif ($receive->is_audio) {
                $bot->send_text(
                    to_mid => $receive->from_mid,
                    text   => 'Thank you for sending a audio.',
                );
            } elsif ($receive->is_location) {
                $bot->send_location(
                    to_mid    => $receive->from_mid,
                    address   => $receive->address,
                    text      => $receive->text,
                    latitude  => $receive->latitude,
                    longitude => $receive->longitude,
                );
            } elsif ($receive->is_sticker) {
                $bot->send_sticker(
                    to_mid   => $receive->from_mid,
                    stkpkgid => $receive->stkpkgid,
                    stkid    => $receive->stkid,
                    stkver   => $receive->stkver,
                );
            } elsif ($receive->is_contact) {
                $bot->send_text(
                    to_mid => $receive->from_mid,
                    text   => sprintf('Thank you for sending %s information.', $receive->display_name),
                );
            }
        } elsif ($receive->is_operation) {
            warn sprintf 'revision=%s, from_mid=%s', $receive->revision, $receive->from_mid;

            if ($receive->is_add_contact) {
                warn "add contact";

                $bot->send_text(
                    to_mid => $receive->from_mid,
                    text   => 'Thank you for adding me to your contact list!',
                );
            } elsif ($receive->is_block_contact) {
                warn "block contact...";
            }
        }
    }

    return [200, [], ["OK"]];
};

__END__

=head1 NAME

echo.psgi - example echo bot

=head1 SYNOPSIS

    $ export CHANNEL_ID=YOUR CHANNEL ID
    $ export CHANNEL_SECRET=YOUR CHANNEL SECRET
    $ export CHANNEL_MID=YOUR CHANNEL MID
    $ plackup eg/echo.psgi

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=cut
