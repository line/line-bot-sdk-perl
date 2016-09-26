package LINEBotFramework::Request;
use strict;
use warnings;

sub new {
    my($class, %args) = @_;
    bless { %args }, $class;
}

sub bot     { $_[0]->{bot} }
sub event   { $_[0]->{event} }
sub message { $_[0]->{message} }
sub context { $_[0]->{context} }
sub session { $_[0]->{session} }

1;
