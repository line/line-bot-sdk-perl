package LINEBotFramework::Response;
use strict;
use warnings;

sub new {
    my($class, %args) = @_;
    bless {
        queues       => [],
        next_context => 'default',
    }, $class;
}

sub next_context {
    my($self, $name) = @_;
    if (@_ == 2) {
        $self->{next_context} = $name;
    } else {
        $self->{next_context};
    }
}

sub render_template {
    my($self, $path, $vars) = @_;
    $self->{xslate}->render($path, $vars);
}

sub finalize {
    my($self, %args) = @_;

    local $self->{bot}      = $args{bot};
    local $self->{xslate}   = $args{xslate};
    local $self->{base_obj} = $args{base_obj};

    for my $args (@{ $self->{queues} }) {
        my $type = delete $args->{type};
        my $method = "exec_$type";
        $self->$method
            (%{ $args },
             to_mid => $args{to_mid},
         );
    }
    return 1;
}

sub send_text {
    my($self, %args) = @_;
    $args{type} ||= 'send_text';
    push @{ $self->{queues} }, \%args;
}

sub exec_send_text {
    my($self, %args) = @_;
    my $text;

    my $page = delete $args{page};
    if (defined $page) {
        my $path = "$page.txt";
        $text = $self->render_template($path, delete $args{template_vars});
    } else {
        $text = $args{text};
    }

    $self->{bot}->send_text(
        %args,
        text => $text,
    );
}

for my $type (qw/ sticker link image location video audio rich_message /) {
    my $method = "send_$type";
    my $enqueue = sub {
        my($self, %args) = @_;
        $args{type} ||= $method;
        push @{ $self->{queues} }, \%args;
    };
    my $exec = sub {
        my($self, %args) = @_;
        $self->{bot}->$method(%args);
    };

    no strict 'refs';
    *{"LINEBotFramework::Response::$method"}      = $enqueue;
    *{"LINEBotFramework::Response::exec_$method"} = $exec;
}

1;
