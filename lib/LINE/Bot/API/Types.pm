package Line::Bot::API::Types;
use strict;
use warnings;

use Type::Library -base;
use Type::Utils -all;
use Types::Standard qw<Str Int Bool Dict Enum Optional ArrayRef HashRef>;
use Types::Common::Numeric qw< PositiveOrZeroInt >;
use Types::Common::String qw< StrLength NonEmptyStr >;

my $ReplyToken = declare ReplyToken => as Str;

# https://developers.line.biz/en/reference/messaging-api/#source-user
declare SourceUser => as Dict[
    type    => Enum["user"],
    userId  => NonEmptyStr,
];

# https://developers.line.biz/en/reference/messaging-api/#source-group
declare SourceGroup => as Dict[
    type    => Enum["group"],
    groupId => NonEmptyStr,
    userId   => Optional[Str],
];

# https://developers.line.biz/en/reference/messaging-api/#source-room
declare SourceRoom => as Dict[
    type    => Enum["room"],
    groupId => NonEmptyStr,
    userId  => Optional[NonEmptyStr],
];

# https://developers.line.biz/en/reference/messaging-api/#wh-text
my $TextMessage = declare TextMessage => as Dict[ id => Str, type => Enum["text"], text => StrLength[1,2000] ];

# https://developers.line.biz/en/reference/messaging-api/#wh-image
my $ImageMessage = declare ImageMessage => as Dict[
    id => Str,
    type => Enum["image"],
    contentProvider => Dict[
        type => Enum["line", "external"],
        previewImageUrl => Optional[NonEmptyStr],
        originalContentUrl => Optional[NonEmptyStr],
    ]
];

# https://developers.line.biz/en/reference/messaging-api/#message-event
declare MessageEvent => as Dict[
    type => Enum["message"],
    replyToken => NonEmptyStr,
    message => $TextMessage | $ImageMessage ,
];

1;
