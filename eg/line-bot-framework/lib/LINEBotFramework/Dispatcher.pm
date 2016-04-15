package LINEBotFramework::Dispatcher;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw/
    new
/;
our @EXPORT_OK = qw/
    context session message text
    is_text is_sticker is_link is_image is_location
    context_is
/;
our %EXPORT_TAGS = (
    DSL => [ qw/
        new
        context session message text
        is_text is_sticker is_link is_image is_location
        context_is
    / ],
);

our $CONTEXT;
our $SESSION;
our $MESSAGE;
our $TEXT;

sub import {
    my($class, @args) = @_;

    my @export_args;
    for my $arg (@args) {
        if ($arg eq '-DSL') {
            push @export_args, ':DSL';
        } else {
            push @export_args, $arg;
        }
    }
    $class->export_to_level(1, $class, @export_args);
}

sub new {
    my $class = shift;
    bless {}, $class;
}

sub context { $CONTEXT }
sub session { $SESSION }
sub message { $MESSAGE }
sub text    { $TEXT }

# is
sub is_text     { $MESSAGE->is_text; }
sub is_sticker  { $MESSAGE->is_sticker; }
sub is_link     { $MESSAGE->is_link; }
sub is_image    { $MESSAGE->is_image; }
sub is_location { $MESSAGE->is_location; }

# context
sub context_is {
    my($context, $callback) = @_;
    $CONTEXT eq $context ? 1 : 0;
}

1;
