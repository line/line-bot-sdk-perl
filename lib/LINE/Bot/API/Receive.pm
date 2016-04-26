package LINE::Bot::API::Receive;
use strict;
use warnings;

use Carp 'croak';
use Digest::SHA 'hmac_sha256';
use JSON::XS;
use MIME::Base64 'decode_base64';

use LINE::Bot::API::Receive::Message;
use LINE::Bot::API::Receive::Operation;
use LINE::Bot::API::Constants;

sub new {
    my($class, $config, $result) = @_;

    my $event_type = $result->{eventType};
    if ($event_type eq EVENT_TYPE_RECEIVING_MESSAGE) {
        $class .= '::Message';
    } elsif ($event_type eq EVENT_TYPE_RECEIVING_OPERATION) {
        $class .= '::Operation';
    } else {
        croak "Undefined eventType: $event_type";
    }

    my $self = $class->new($config, $result);

}

sub new_from_json {
    my($class, $config, $json) = @_;
    my $data = decode_json $json;

    my $results = [];
    for my $result (@{ $data->{result} }) {
        push @{ $results }, $class->new($config, $result);
    }

    $results;
}

sub new_from_plack {
    my($class, $json) = @_;
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

sub is_message   { 0 }
sub is_operation { 0 }

sub id { $_[0]->{result}{id} }

sub is_valid_event {
    my $self = shift;
    my $config = $self->{config};
    my $result = $self->{result};
    $result->{toChannel} eq $config->{channel_id} && $result->{fromChannel} eq BOT_API_RECEIVING_CHANNEL_ID && $result->{from} eq BOT_API_RECEIVING_CHANNEL_MID;
}


sub is_text     { 0 }
sub is_image    { 0 }
sub is_video    { 0 }
sub is_audio    { 0 }
sub is_location { 0 }
sub is_sticker  { 0 }
sub is_contact  { 0 }

1;
__END__

=head1 NAME

LINE::Bot::API::Receive - Handler for recieving events from LINE Bot API

=head1 SYNOPSIS

    use strict;
    use warnings;
    use LINE::Bot::API;

    my $bot = LINE::Bot::API->new(
        channel_id     => 'YOUR LINE BOT Channel ID',
        channel_secret => 'YOUR LINE BOT Channel Secret',
        channel_mid    => 'YOUR LINE BOT MID',
    );

    my $requests = $bot->create_requests_from_json($json);
    for my $req (@{ $requests }) {
        if ($req->is_message) {

            say $req->content_id;
            say $req->from_mid;
            say $req->created_time; # createdTime

            if ($req->is_text) {
                say $req->text;
            } elsif ($req->is_image) {
                # LINE::Bot::API::Receive::Message::Image has no getter method
            } elsif ($req->is_video) {
                # LINE::Bot::API::Receive::Message::Video has no getter method
            } elsif ($req->is_audio) {
                # LINE::Bot::API::Receive::Message::Audio has no getter method
            } elsif ($req->is_location) {
                say $req->text; # alias of title
                say $req->title;
                say $req->address;
                say $req->latitude;
                say $req->longitude;
            } elsif ($req->is_sticker) {
                say $req->stkpkgid;
                say $req->stkid;
                say $req->stkver;
                say $req->stktxt;
            } elsif ($req->is_contact) {
                say $req->mid;
                say $req->display_name;
            }
        } elsif ($req->is_operation) {

            say $req->revision;
            say $req->from_mid;

            if ($req->is_add_contact) {
                # LINE::Bot::API::Receive::Operation::AddContact has no getter method
            } elsif ($req->is_block_contact) {
                # LINE::Bot::API::Receive::Operation::BlockContact has no getter method
            }
        }
    }

=head1 DESCRIPTION

LINE::Bot::API::Receive is a handler to receive events from LINE BOT API.
Allows you to easily handle operatiion messages.

Using instance method directly is not-recommended.
Please use L<create_requests_from_json($json)|LINE::Bot::API/create_receives_from_json()> of LINE::Bot::API instead.

See also L<LINE Developers - BOT API - API reference|https://developers.line.me/bot-api/api-reference> for more deitals of these package's getter method.

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=cut
