package LINE::Bot::API::Client;
use strict;
use warnings;

use Carp 'croak';
use File::Basename 'basename';

sub new {
    my(undef, %args) = @_;
    my $backend = 'Furl';
    if ($args{http_client} && $args{http_client}{backend}) {
        $backend = $args{http_client}{backend};
    }
    my $klass   = join '::', __PACKAGE__, $backend;
    eval "use $klass;"; ## no critic
    croak $@ if $@;
    $klass->new(%args);
}

1;
