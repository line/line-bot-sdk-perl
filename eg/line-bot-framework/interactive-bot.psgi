use strict;
use warnings;
use lib 'lib';

use Plack::Request;

use LINE::Bot::API;
use LINEBotFramework;

my $channel_secret         = $ENV{CHANNEL_SECRET};
my $channel_access_token   = $ENV{CHANNEL_ACCESS_TOKEN};
my $messaging_api_endpoint = $ENV{MESSAGING_API_ENDPOINT};
my $callback_url           = $ENV{CALLBACK_URL} // '/perl/callback';

my $bot = LINE::Bot::API->new(
    channel_secret         => $channel_secret,
    channel_access_token   => $channel_access_token,
    messaging_api_endpoint => $messaging_api_endpoint,
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

    unless ($req->method eq 'POST' && $req->path eq $callback_url) {
        return [200, [], ['Not Found']];
    }

    unless ($framework->validate_signature($req->content, $req->header('X-Line-Signature'))) {
        return [200, [], ['bad request']];
    }

    $framework->dispatcher($req->content);

    return [200, [], ["OK"]];
};

__END__

=head1 NAME

interactive-bot.psgi - A example bot with a bot framework

=head1 SYNOPSIS

    $ export CHANNEL_SECRET=YOUR CHANNEL SECRET
    $ export CHANNEL_ACCESS_TOKEN=YOUR CHANNEL ACCESS TOKEN
    $ plackup eg/interactive-bot.psgi

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=cut
