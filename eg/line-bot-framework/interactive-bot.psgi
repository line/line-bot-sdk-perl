use strict;
use warnings;
use lib 'lib';

use Plack::Request;

use LINE::Bot::API;
use LINEBotFramework;

my $channel_id     = $ENV{CHANNEL_ID};
my $channel_secret = $ENV{CHANNEL_SECRET};
my $channel_mid    = $ENV{CHANNEL_MID};

my $bot = LINE::Bot::API->new(
    channel_id     => $channel_id,
    channel_secret => $channel_secret,
    channel_mid    => $channel_mid,
);

my $framework = LINEBotFramework->new(
    base_class    => 'ExampleBot',
    bot           => $bot,
    xslate_config => {
        path      => 'bot-tmpl',
    },
);

sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    unless ($req->method eq 'POST' && $req->path eq '/perl/callback') {
        return [404, [], ['Not Found']];
    }

    unless ($framework->signature_validation($req->content, $req->header('X-LINE-ChannelSignature'))) {
        return [470, [], ['bad request']];
    }

    $framework->dispatcher($req->content);

    return [200, [], ["OK"]];
};

__END__

=head1 NAME

interactive-bot.psgi - A example bot with a bot framework

=head1 SYNOPSIS

    $ export CHANNEL_ID=YOUR CHANNEL ID
    $ export CHANNEL_SECRET=YOUR CHANNEL SECRET
    $ export CHANNEL_MID=YOUR CHANNEL MID
    $ plackup eg/interactive-bot.psgi

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=cut
