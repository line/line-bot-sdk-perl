package LINE::Bot::API::Event::Things::ActionResult;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

use Carp 'carp';

my %TYPE2CLASS = (
    void => 'LINE::Bot::API::Event::Things::ActionResult::Void',
    binary => 'LINE::Bot::API::Event::Things::ActionResult::Binary',
);

sub new {
    my($class, %args) = @_;

    my $type = $args{type};
    my $class_to_instantiate = $TYPE2CLASS{$type};
    unless ($class_to_instantiate) {
        carp 'Unsupported ActionResult type: ' . $type;
        $class_to_instantiate = $class;
    }

    bless { %args }, $class_to_instantiate;
}

package LINE::Bot::API::Event::Things::ActionResult::Void {
    use parent 'LINE::Bot::API::Event::Things::ActionResult';
}

package LINE::Bot::API::Event::Things::ActionResult::Binary {
    use parent 'LINE::Bot::API::Event::Things::ActionResult';

    sub data { $_[0]->{data} }
}

1;
