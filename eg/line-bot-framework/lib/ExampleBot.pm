package ExampleBot;
use strict;
use warnings;

use JSON::XS;

sub new {
    my($class, %args) = @_;
    my $self = bless \%args, $class;
    return $self;
}

# chatting context manager
# you should use memcached, redis, rdbms for production

my $CONTEXT = +{};

sub get_context {
    my($self, $mid) = @_;

    my $json = $CONTEXT->{$mid};
    return ('default', +{}) unless $json;

    my $data =  decode_json($json);
    return ($data->{context}, $data);
}

sub set_context {
    my($self, $mid, $context, $session) = @_;

    $session->{context} = $context;
    $CONTEXT->{$mid} = encode_json($session);
}

1;
