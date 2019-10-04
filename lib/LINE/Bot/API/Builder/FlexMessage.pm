package LINE::Bot::API::Builder::FlexMessage;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    die "`json` attribute is required" unless defined $args{json};
    return bless { _json => $args{json} }, $class;
}

sub build {
    my ($self) = @_;
    return $self->{_build} //= decode_json($self->{_json});
}

1;

__END__

=head1 NAME

LINE::Bot::API::Builder::FlexMessage

=head1 SYNOPSIS

    my $message = LINE::Bot::API::Builder::FlexMessage->new( json => $json_text );

    $bot->push_message( $user_id, $message->build );

=head1 DESCRIPTION

This module can be used to convert the output of L<Flex Message Simulator|https://developers.line.biz/console/fx/> to an object.

Structurally, a flex message is represented as an object in JSON with
smaller components. Here's an minimal example:

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

This module merely parse the given json text provided by the C<json>
attribute and directly use the structure as the message content.

It is created to let developers able to basically paste the JSON text
produced by Flex Message Simular into code.

=head1 METHODS

=over 4

=item new( json => $json_text )

Object constructure. The "json" parameter is required. The value
should be a normal scalar variable containing json text.

=item build()

Returns the message object that can be pass thru push_message method.

=back

=head1 SEE ALSO

L<Flex Message Simulator|https://developers.line.biz/console/fx/>
