package LINE::Bot::API::Builder::FlexMessage;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    return bless { _json => $args{json} }, $class;
}

sub build {
    my ($self) = @_;
    return $self->{_build} //= decode_json($self->{_json});
}

1;

__END__

=head1 SYNOPSIS

    my $message = LINE::Bot::API::Builder::FlexMessage->new( json => $json_text );

    $bot->push_message( $user_id, $message->build );

=head1 DESCRIPTION

This module can be used to convert the output of L<Flex Message Simulator|https://developers.line.biz/console/fx/> to an object.

Structurally, a flex message is represented as an object in JSON with smaller components. Here's an minimal example:

    {
      "type": "flex",
      "altText": "This is a Flex Message",
      "contents": {
        "type": "bubble",
        "body": {
          "type": "box",
          "layout": "horizontal",
          "contents": [
            {
              "type": "text",
              "text": "Hello,"
            },
            {
              "type": "text",
              "text": "World!"
            }
          ]
        }
      }
    }

=head1 SEE ALSO

L<Flex Message Simulator|https://developers.line.biz/console/fx/>
