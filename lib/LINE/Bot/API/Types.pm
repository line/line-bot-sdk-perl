package Line::Bot::API::Types;
use strict;
use warnings;

use Type::Library -base;
use Type::Utils -all;
use Types::Standard qw<Str Int Bool Dict Optional ArrayRef HashRef>;
use Types::Common::Numeric qw< PositiveOrZeroInt >;

declare TextMessage => as Dict[ type => Str, text => Str ], where {
    $_->{type} eq 'text' && length( $_->{text} ) <= 2000
};

1;
