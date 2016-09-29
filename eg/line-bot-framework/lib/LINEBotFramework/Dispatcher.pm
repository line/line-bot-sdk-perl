package LINEBotFramework::Dispatcher;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw/
    new
/;
our @EXPORT_OK = qw/
    context session event text
    is_text is_image is_video is_audio is_location is_sticker
    context_is
/;
our %EXPORT_TAGS = (
    DSL => [ qw/
        new
        context session event text
        is_text is_image is_video is_audio is_location is_sticker
        context_is
    / ],
);

our $CONTEXT;
our $SESSION;
our $EVENT;
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
sub event   { $EVENT }
sub text    { $TEXT }

# is
sub is_text     { $EVENT->is_text_message; }
sub is_image    { $EVENT->is_image_message; }
sub is_video    { $EVENT->is_video_message; }
sub is_audio    { $EVENT->is_audio_message; }
sub is_location { $EVENT->is_location_message; }
sub is_sticker  { $EVENT->is_sticker_message; }

# context
sub context_is {
    my($context, $callback) = @_;
    $CONTEXT eq $context ? 1 : 0;
}

1;
