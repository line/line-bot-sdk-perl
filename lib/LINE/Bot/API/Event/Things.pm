package LINE::Bot::API::Event::Things;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

use Carp 'carp';
our @CARP_NOT = qw( LINE::Bot::API::Event::Things LINE::Bot::API::Event LINE::Bot::API);

my %TYPE2CLASS = (
    link   => 'LINE::Bot::API::Event::Things::Link',
    unlink => 'LINE::Bot::API::Event::Things::Unlink',
);

sub new {
    my($class, %args) = @_;

    my $type = $args{things}{type};
    my $things_class = $TYPE2CLASS{$type};
    unless ($things_class) {
        carp 'Unsupported Things type: ' . $type;
        $things_class = $class;
    }

    bless { %args }, $things_class;
}

sub is_things_event { 1 }

sub things_device_id { $_[0]->{things}{deviceId} }
sub things_type      { $_[0]->{things}{type} }

sub is_device_link   { 0 }
sub is_device_unlink { 0 }

package LINE::Bot::API::Event::Things::Link {
    use parent 'LINE::Bot::API::Event::Things';

    sub is_device_link { 1 }
}

package LINE::Bot::API::Event::Things::Unlink {
    use parent 'LINE::Bot::API::Event::Things';

    sub is_device_unlink { 1 }
}

1;
