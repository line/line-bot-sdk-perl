package ExampleBot::Operation;
use strict;
use warnings;

use LINEBotFramework::Response;

sub add_contact {
    my($class, $req) = @_;

    my $res = LINEBotFramework::Response->new;

    $res->send_text(
        text => 'Welcome to line-bot-framework example bot!',
    );

    $res->send_text(
        page          => 'help',
        template_vars => { app_name => 'example bot' },
    );

    $res;
}


1;
