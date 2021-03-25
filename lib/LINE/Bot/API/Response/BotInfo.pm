package LINE::Bot::API::Response::BotInfo;
use strict;
use warnings;
use parent 'LINE::Bot::API::Response::Common';

sub userId         { $_[0]->{userId} }
sub basicId        { $_[0]->{basicId} }
sub premiumId      { $_[0]->{premiumId} }
sub displayName    { $_[0]->{displayName} }
sub pictureUrl     { $_[0]->{pictureUrl} }
sub chatMode       { $_[0]->{chatMode} }
sub markAsReadMode { $_[0]->{markAsReadMode} }

1;

__END__

=head1 NAME

LINE::Bot::API::Response::BotInfo

=head1 DESCRIPTION

This cllass corresponds to the response object of "Bot Info" API as described in this page: L<https://developers.line.biz/en/reference/messaging-api/#get-bot-info>

For each top-level properties, there is a corresponding method with the same name which provides access to the value of the property.

=head1 METHODS

=over 4

=item userId

=item basicId

=item premiumId

=item displayName

=item pictureUrl

=item chatMode

=item markAsReadMode

=back
