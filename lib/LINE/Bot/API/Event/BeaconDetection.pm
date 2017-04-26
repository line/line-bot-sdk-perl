package LINE::Bot::API::Event::BeaconDetection;
use strict;
use warnings;
use parent 'LINE::Bot::API::Event::Base';

sub is_beacon_detection_event { 1 }

sub beacon_hwid { $_[0]->{beacon}{hwid} }
sub beacon_type { $_[0]->{beacon}{type} }
sub beacon_device_message { pack 'H*', $_[0]->{beacon}{dm} }

1;
