package ExampleBot::Memo;
use strict;
use warnings;

use LINEBotFramework::Response;

sub add {
    my($class, $req) = @_;
    return unless $req->message->is_text;

    my $res = LINEBotFramework::Response->new;

    my $session = $req->session;
    $session->{memo}{stack} ||= [];
    push @{ $session->{memo}{stack} }, $req->message->text;

    $res->next_context($req->context); # next context is not changed

    return $res;
}


sub finish {
    my($class, $req) = @_;

    my $res = LINEBotFramework::Response->new;

    $res->send_text(
        text => 'The memos which you wrote are as follows.',
    );

    for my $memo (@{ $req->session->{memo}{stack} }) {
        $res->send_text(
            text => $memo,
        );
    }

    my $session = $req->session;
    $session->{memo}{stack} = [];

    $res->send_sticker(
        stkid    => int(rand(10))+1,
        stkpkgid => 1,
        stkver   => 100,
    );

    $res;
}

1;

