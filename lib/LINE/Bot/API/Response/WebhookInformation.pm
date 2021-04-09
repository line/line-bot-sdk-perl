package LINE::Bot::API::Response::WebhookInformation;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub endpoint { $_[0]->{endpoint} }
sub active   { $_[0]->{active} }

1;

__END__

=head1 NAME

LINE::Bot::API::Response::WebhookInformation

=head1 DESCRIPTION

This cllass corresponds to the response object of "Get Webhook Endpoint Information" API as described in this page: L<https://developers.line.biz/en/reference/messaging-api/#get-webhook-endpoint-information>.

For each top-level properties, there is a corresponding method with the same name which provides access to the value of the property.

=head1 METHODS

=over 4

=item endpoint

=item active

=back
