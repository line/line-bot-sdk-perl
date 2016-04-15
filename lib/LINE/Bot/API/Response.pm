package LINE::Bot::API::Response;
use strict;
use warnings;

use LINE::Bot::API::Constants;

sub new {
    my($class, $data) = @_;

    if ($data->{http_status} eq '200') {
        $class .= '::Successful';
    } else {
        $class .= '::Failed';
    }

    bless {
        %{ $data },
    }, $class;
}

sub http_status   { $_[0]->{http_status} }
sub is_success    { }

package LINE::Bot::API::Response::Successful {
    use parent 'LINE::Bot::API::Response';

    sub is_success { 1 }
    sub version    { $_[0]->{version} }
    sub message_id { $_[0]->{messageId} }
    sub timestamp  { $_[0]->{timestamp} }
    sub failed     { $_[0]->{failed} }
}

package LINE::Bot::API::Response::Failed {
    use parent 'LINE::Bot::API::Response';

    sub is_success     { 0 }
    sub status_code    { $_[0]->{statusCode} }
    sub status_message { $_[0]->{statusMessage} }
}

1;

