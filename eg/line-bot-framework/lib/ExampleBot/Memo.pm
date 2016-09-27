package ExampleBot::Memo;
use strict;
use warnings;

use LINEBotFramework::Response;

sub add {
    my($class, $req) = @_;
    return unless $req->event->is_text_message;

    my $res = LINEBotFramework::Response->new;

    my $session = $req->session;
    $session->{memo}{stack} ||= [];
    push @{ $session->{memo}{stack} }, $req->event->text;

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
        package_id => '1',
        sticker_id => int(rand(10))+1 + '',
    );

    $res;
}

1;

