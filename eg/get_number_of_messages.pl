#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use LINE::Bot::API;
use Data::Dumper;
use Time::Piece qw/localtime/;

my $date = shift(@ARGV) // localtime->strftime('%Y%m%d');

my $bot = LINE::Bot::API->new(
    channel_secret       => $ENV{CHANNEL_SECRET},
    channel_access_token => $ENV{CHANNEL_ACCESS_TOKEN},
);
for my $method (qw(get_number_of_sent_reply_messages get_number_of_sent_push_messages get_number_of_sent_multicast_messages)) {
    print "-- $method\n";
    print Dumper($bot->$method($date));
}

