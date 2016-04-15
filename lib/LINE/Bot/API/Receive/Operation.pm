package LINE::Bot::API::Receive::Operation;
use strict;
use warnings;
use parent 'LINE::Bot::API::Receive';

use LINE::Bot::API::Constants;

sub new {
    my($class, $config, $result) = @_;

    my $op_type = $result->{content}{opType};
    if ($op_type eq OP_NOTIFIED_ADD_CONTACT) {
        $class .= '::AddContact';
    } elsif ($op_type eq OP_NOTIFIED_BLOCK_CONTACT) {
        $class .= '::BlockContact';
    }

    bless {
        config => $config,
        result => $result,
    }, $class;
}

sub is_operation { 1 }

sub revision     { $_[0]->{result}{content}{revision} }
sub from_mid     { $_[0]->{result}{content}{params}[0] }

package LINE::Bot::API::Receive::Operation::AddContact {
    use parent 'LINE::Bot::API::Receive::Operation';

    sub is_add_contact { 1 }
}

package LINE::Bot::API::Receive::Operation::BlockContact {
    use parent 'LINE::Bot::API::Receive::Operation';

    sub is_block_contact { 1 }
}

1;
