package LINE::Bot::API::Event;
use strict;
use warnings;

use Carp qw/ carp /;
our @CARP_NOT = qw( LINE::Bot::API::Event LINE::Bot::API);

use Digest::SHA 'hmac_sha256';
use JSON::XS 'decode_json';
use MIME::Base64 'decode_base64';

use LINE::Bot::API::Event::Message;
use LINE::Bot::API::Event::Follow;
use LINE::Bot::API::Event::Unfollow;
use LINE::Bot::API::Event::Join;
use LINE::Bot::API::Event::Leave;
use LINE::Bot::API::Event::Postback;
use LINE::Bot::API::Event::BeaconDetection;

my %TYPE2CLASS = (
    message  => 'LINE::Bot::API::Event::Message',
    follow   => 'LINE::Bot::API::Event::Follow',
    unfollow => 'LINE::Bot::API::Event::Unfollow',
    join     => 'LINE::Bot::API::Event::Join',
    leave    => 'LINE::Bot::API::Event::Leave',
    postback => 'LINE::Bot::API::Event::Postback',
    beacon   => 'LINE::Bot::API::Event::BeaconDetection',
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
