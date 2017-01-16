package LINE::Bot::API::Response::Common;
use strict;
use warnings;

use LINE::Bot::API::Response::Error;

sub new {
    my($class, %args) = @_;
    my $self = bless { %args }, $class;
    bless $self, 'LINE::Bot::API::Response::Error' unless $self->is_success;
    $self;
}

sub is_success        { $_[0]->{http_status} == 200 }
sub http_status       { $_[0]->{http_status} }
sub x_line_request_id { $_[0]->{http_headers}->header('X-Line-Request-Id') }

1;
