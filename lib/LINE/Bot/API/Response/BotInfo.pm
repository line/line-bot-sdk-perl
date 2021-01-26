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
