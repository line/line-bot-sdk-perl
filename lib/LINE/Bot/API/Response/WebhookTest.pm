package LINE::Bot::API::Response::WebhookTest;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub success    { $_[0]->{success} }
sub timestamp  { $_[0]->{timestamp} }
sub statusCode { $_[0]->{statusCode} }
sub reason     { $_[0]->{reason} }
sub detail     { $_[0]->{detail} }

1;

__END__

=head1 NAME

LINE::Bot::API::Response::WebhookTest

=head1 DESCRIPTION

This cllass corresponds to the response object of "Test Webhook Endpoint" API as described in this page: L<https://developers.line.biz/en/reference/messaging-api/#test-webhook-endpoint>

For each top-level properties, there is a corresponding method with the same name which provides access to the value of the property.

=head1 METHODS

=over 4

=item success

=item timestamp

=item statusCode

=item reason

=item detail

=back
