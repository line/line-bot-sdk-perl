package LINE::Bot::API::Event::Message;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

use Carp 'carp';
our @CARP_NOT = qw( LINE::Bot::API::Event::Message LINE::Bot::API::Event LINE::Bot::API);

my %TYPE2CLASS = (
    text     => 'LINE::Bot::API::Event::Message::Text',
    image    => 'LINE::Bot::API::Event::Message::Image',
    video    => 'LINE::Bot::API::Event::Message::Video',
    audio    => 'LINE::Bot::API::Event::Message::Audio',
    location => 'LINE::Bot::API::Event::Message::Location',
    sticker  => 'LINE::Bot::API::Event::Message::Sticker',
    file     => 'LINE::Bot::API::Event::Message::File',
);

sub new {
    my($class, %args) = @_;

    my $type = $args{message}{type};
    my $message_class = $TYPE2CLASS{$type};
    unless ($message_class) {
        carp 'Unsupported message type: ' . $type;
        $message_class = $class;
    }

    bless { %args }, $message_class;
}

sub is_message_event { 1 }

sub message_id    { $_[0]->{message}{id} }

sub message_type  { $_[0]->{message}{type} }

sub is_text_message     { 0 }
sub is_image_message    { 0 }
sub is_video_message    { 0 }
sub is_audio_message    { 0 }
sub is_location_message { 0 }
sub is_sticker_message  { 0 }
sub is_file_message     { 0 }

package LINE::Bot::API::Event::Message::Text {
    use parent 'LINE::Bot::API::Event::Message';

    sub is_text_message { 1 }

    sub text { $_[0]->{message}{text} }
}

package LINE::Bot::API::Event::Message::Image {
    use parent 'LINE::Bot::API::Event::Message';

    sub is_image_message { 1 }

    sub content_provider { $_[0]->{message}{contentProvider} }
}

package LINE::Bot::API::Event::Message::Video {
    use parent 'LINE::Bot::API::Event::Message';

    sub is_video_message { 1 }

    sub content_provider { $_[0]->{message}{contentProvider} }
}

package LINE::Bot::API::Event::Message::Audio {
    use parent 'LINE::Bot::API::Event::Message';

    sub is_audio_message { 1 }

    sub content_provider { $_[0]->{message}{contentProvider} }
}

package LINE::Bot::API::Event::Message::Location {
    use parent 'LINE::Bot::API::Event::Message';

    sub is_location_message { 1 }

    sub title     { $_[0]->{message}{title} }
    sub address   { $_[0]->{message}{address} }
    sub latitude  { $_[0]->{message}{latitude} }
    sub longitude { $_[0]->{message}{longitude} }
}

package LINE::Bot::API::Event::Message::Sticker {
    use parent 'LINE::Bot::API::Event::Message';

    sub is_sticker_message { 1 }

    sub package_id { $_[0]->{message}{packageId} }
    sub sticker_id { $_[0]->{message}{stickerId} }
}

package LINE::Bot::API::Event::Message::File {
    use parent 'LINE::Bot::API::Event::Message';

    sub is_file_message { 1 }

    sub file_name { $_[0]->{message}{fileName} }
    sub file_size { $_[0]->{message}{fileSize} }
}

1;
