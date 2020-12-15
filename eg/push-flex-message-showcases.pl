use strict;
use warnings;

use FindBin '$Bin';
use File::Glob ':bsd_glob';
use JSON;
use Data::Dumper qw(Dumper);

use LINE::Bot::API;

my $channel_secret         = $ENV{CHANNEL_SECRET} or die "requiers env: CHANNEL_SECRET";
my $channel_access_token   = $ENV{CHANNEL_ACCESS_TOKEN} or die "requires env: CHANNEL_ACCESS_TOKEN";
my $messaging_api_endpoint = $ENV{MESSAGING_API_ENDPOINT};

my($to_id) = @ARGV;

$to_id or die "requires \$ARGV[0]: a user ID";

my $bot = LINE::Bot::API->new(
    channel_secret         => $channel_secret,
    channel_access_token   => $channel_access_token,
    $messaging_api_endpoint ? (
        messaging_api_endpoint => $messaging_api_endpoint,
    ):(),
);

my $json = JSON->new->utf8;

for my $file (bsd_glob($Bin . '/flex-message-showcases/*.json')) {

    my ($fh, $flex_message);
    print "# $file\n";
    open($fh, '<', $file);
    $flex_message = do { local $/; $json->decode(scalar <$fh>) };
    close($fh);

    my $builder = LINE::Bot::API::Builder::SendMessage->new();
    $builder->add_text( text => "Showcase: " . ($file =~ s{^.+\/}{}r) );
    $builder->add($flex_message);

    my $messages = $builder->build;

    print $json->encode($messages);
    next;

    my $res = $bot->push_message($to_id, $messages);
    unless ($res->is_success) {
        print Dumper([ res => $res ]);
    }
}


__END__

=head1 NAME

push-flex-message-showcases.pl - example script for push a Flex Message

=head1 SYNOPSIS

    $ export CHANNEL_SECRET=YOUR CHANNEL SECRET
    $ export CHANNEL_ACCESS_TOKEN=YOUR CHANNEL ACCESS TOKEN
    $ perl push-flex-message-showcases.pl <TO_ID>

=head1 References:

Flex Message: L<https://developers.line.biz/en/reference/messaging-api/#flex-message>

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=cut
