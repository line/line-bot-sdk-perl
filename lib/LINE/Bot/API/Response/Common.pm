package LINE::Bot::API::Response::Common;
use strict;
use warnings;

sub new {
    my($class, %args) = @_;
    bless { %args }, $class;
}

sub is_success  { $_[0]->{http_status} == 200 }
sub http_status { $_[0]->{http_status} }

1;
