package LINE::Bot::API::Receive::Message;
use strict;
use warnings;
use parent 'LINE::Bot::API::Receive';

use LINE::Bot::API::Constants;

sub new {
    my($class, $config, $result) = @_;

    my $content_type = $result->{content}{contentType};
    if ($content_type eq CONTENT_TEXT) {
        $class .= '::Text';
    } elsif ($content_type eq CONTENT_IMAGE) {
        $class .= '::Image';
    } elsif ($content_type eq CONTENT_VIDEO) {
        $class .= '::Video';
    } elsif ($content_type eq CONTENT_AUDIO) {
        $class .= '::Audio';
    } elsif ($content_type eq CONTENT_LOCATION) {
        $class .= '::Location';
    } elsif ($content_type eq CONTENT_STICKER) {
        $class .= '::Sticker';
    } elsif ($content_type eq CONTENT_CONTACT) {
        $class .= '::Contact';
    }

    bless {
        config => $config,
        result => $result,
    }, $class;
}

sub is_message { 1 }

sub is_sent_me {
    my $self = shift;
    my $my_mid = $self->{config}{channel_mid};
    grep { $my_mid } @{ $self->{result}{content}{to} };
}

sub content_id   { $_[0]->{result}{content}{id} }
sub created_time { $_[0]->{result}{content}{createdTime} }
sub from_mid     { $_[0]->{result}{content}{from} }

package LINE::Bot::API::Receive::Message::Text {
    use parent 'LINE::Bot::API::Receive::Message';

    sub is_text { 1 }

    sub text { $_[0]->{result}{content}{text} }
}

package LINE::Bot::API::Receive::Message::Image {
    use parent 'LINE::Bot::API::Receive::Message';

    sub is_image { 1 }
}

package LINE::Bot::API::Receive::Message::Video {
    use parent 'LINE::Bot::API::Receive::Message';

    sub is_video { 1 }
}

package LINE::Bot::API::Receive::Message::Audio {
    use parent 'LINE::Bot::API::Receive::Message';

    sub is_audio { 1 }
}

package LINE::Bot::API::Receive::Message::Location {
    use parent 'LINE::Bot::API::Receive::Message';

    sub is_location { 1 }

    sub text      { $_[0]->{result}{content}{location}{title} } # `$_[0]->{result}{content}{text} }` always be null
    sub title     { $_[0]->{result}{content}{location}{title} }
    sub address   { $_[0]->{result}{content}{location}{address} }
    sub latitude  { $_[0]->{result}{content}{location}{latitude} }
    sub longitude { $_[0]->{result}{content}{location}{longitude} }
}

package LINE::Bot::API::Receive::Message::Sticker {
    use parent 'LINE::Bot::API::Receive::Message';

    sub is_sticker { 1 }

    sub stkpkgid { $_[0]->{result}{content}{contentMetadata}{STKPKGID} }
    sub stkid    { $_[0]->{result}{content}{contentMetadata}{STKID} }
    sub stkver   { $_[0]->{result}{content}{contentMetadata}{STKVER} }
    sub stktxt   { $_[0]->{result}{content}{contentMetadata}{STKTXT} }
}

package LINE::Bot::API::Receive::Message::Contact {
    use parent 'LINE::Bot::API::Receive::Message';

    sub is_contact { 1 }

    sub mid          { $_[0]->{result}{content}{contentMetadata}{mid} }
    sub display_name { $_[0]->{result}{content}{contentMetadata}{displayName} }
}

1;
