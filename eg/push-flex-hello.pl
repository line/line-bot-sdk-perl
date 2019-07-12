use strict;
use warnings;
use Data::Dumper qw(Dumper);

use LINE::Bot::API;

# poorman lorem lipsum generator.
sub random_txt {
    my $n = rand(64) + 12;
    my $str = q{Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.};
    return substr($str, rand(length($str) - $n), $n);
}

my $channel_secret         = $ENV{CHANNEL_SECRET} or die "requiers env: CHANNEL_SECRET";
my $channel_access_token   = $ENV{CHANNEL_ACCESS_TOKEN} or die "requires env: CHANNEL_ACCESS_TOKEN";
my $messaging_api_endpoint = $ENV{MESSAGING_API_ENDPOINT};

my($to_id) = @ARGV;

$to_id or die "requires \$ARGV[0]: a user ID";

my @messages = (
    +{
        type => "flex",
        altText => "Hello World",
        contents => {
            "type" => "bubble",
            "body" => {
                "type" => "box",
                "layout" => "vertical",
                "contents" => [
                    +{
                        "type" => "text",
                        "text" => "Hello World",
                        "size" => "xl",
                        "gravity" => "bottom",
                    },
                    +{
                        "type" => "text",
                        "text" => random_txt(),
                        "gravity" => "bottom",
                    },
                ]
            },
            footer => {
                "type" => "box",
                "layout" => "vertical",
                contents => [
                    +{
                        "type" => "text",
                        "align" => "end",
                        "text" => "".localtime(),
                    },
                    +{
                        "type" => "button",
                        "style" => "link",
                        "height" => "sm",
                        "action" => {
                            "type" => "uri",
                            "label" => "URI action sample",
                            "uri" => "https://example.com",
                            "altUri" => {
                                "desktop" => "https://example.com/desktop"
                            }
                        }
                    },
                ]
            }
        }
    }
);

my $bot = LINE::Bot::API->new(
    channel_secret         => $channel_secret,
    channel_access_token   => $channel_access_token,
    $messaging_api_endpoint ? (
        messaging_api_endpoint => $messaging_api_endpoint,
    ):(),
);

my $res = $bot->push_message($to_id, \@messages);

unless ($res->is_success) {
    print Dumper([ res => $res ]);
}


__END__

=head1 NAME

push-flex-hello.pl - example script for push a Flex Message

=head1 SYNOPSIS

    $ export CHANNEL_SECRET=YOUR CHANNEL SECRET
    $ export CHANNEL_ACCESS_TOKEN=YOUR CHANNEL ACCESS TOKEN
    $ perl push-flex-hello.pl <TO_ID>

=head1 References:

Flex Message: L<https://developers.line.biz/en/reference/messaging-api/#flex-message>

=head1 COPYRIGHT & LICENSE

Copyright 2016 LINE Corporation

This Software Development Kit is licensed under The Artistic License 2.0.
You may obtain a copy of the License at
https://opensource.org/licenses/Artistic-2.0

=cut
