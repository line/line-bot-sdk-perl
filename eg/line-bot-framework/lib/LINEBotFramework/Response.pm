package LINEBotFramework::Response;
use strict;
use warnings;

use LINE::Bot::API::Builder::SendMessage;

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
    return 1 unless scalar(@{ $self->{queues} });

    local $self->{bot}      = $args{bot};
    local $self->{xslate}   = $args{xslate};
    local $self->{base_obj} = $args{base_obj};

    my $messages = LINE::Bot::API::Builder::SendMessage->new;

    for my $queue (@{ $self->{queues} }) {
        my $type = delete $queue->{type};
        my $method = "exec_$type";
        $self->$method($messages, %{ $queue });
    }

    my $res = $self->{bot}->reply_message($args{reply_token}, $messages->build);

    # error handling
    unless ($res->is_success) {
        warn $res->message;
        for my $detail (@{ $res->details // []}) {
                if ($detail && ref($detail) eq 'HASH') {
                    warn "    detail: " . $detail->{message};
                }
            }
    }

    return 1;
}

sub send_text {
    my($self, %args) = @_;
    $args{type} ||= 'text';
    push @{ $self->{queues} }, \%args;
}

sub exec_text {
    my($self, $messages, %args) = @_;
    my $text;

    my $page = delete $args{page};
    if (defined $page) {
        my $path = "$page.txt";
        $text = $self->render_template($path, delete $args{template_vars});
    } else {
        $text = $args{text};
    }

    $messages->add_text(
        text => $text,
    );
}

for my $type (qw/ image video audio sticker location imagemap template /) {
    my $add_method = "add_$type";
    my $enqueue = sub {
        my($self, %args) = @_;
        $args{type} ||= $type;
        push @{ $self->{queues} }, \%args;
    };
    my $exec = sub {
        my($self, $messages, %args) = @_;
        $messages->$add_method(%args);
    };

    no strict 'refs';
    *{"LINEBotFramework::Response::send_$type"} = $enqueue;
    *{"LINEBotFramework::Response::exec_$type"} = $exec;
}

1;
