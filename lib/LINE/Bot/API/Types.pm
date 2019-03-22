package Line::Bot::API::Types;
use strict;
use warnings;

use Type::Library -base;
use Type::Utils -all;
use Types::Standard qw<Str Int Num Bool Dict Enum Optional ArrayRef HashRef>;
use Types::Common::Numeric qw< PositiveOrZeroInt PositiveOrZeroNum >;
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

my $ContentProvider = Dict [
    type => Enum["line", "external"],
    previewImageUrl => Optional[NonEmptyStr],
    originalContentUrl => Optional[NonEmptyStr],
];

# https://developers.line.biz/en/reference/messaging-api/#wh-text
my $TextMessage = declare TextMessage => as Dict[ id => Str, type => Enum["text"], text => StrLength[1,2000] ];

# https://developers.line.biz/en/reference/messaging-api/#wh-image
my $ImageMessage = declare ImageMessage => as Dict[
    id => NonEmptyStr,
    type => Enum["image"],
    contentProvider => $ContentProvider,
];

# https://developers.line.biz/en/reference/messaging-api/#wh-video
my $VideoMessage = declare VideoMessage => as Dict[
    id => NonEmptyStr,
    type => Enum["video"],
    duration => PositiveOrZeroInt,
    contentProvider => $ContentProvider,
];

# https://developers.line.biz/en/reference/messaging-api/#wh-audio
my $AudioMessage = declare AudioMessage => as Dict[
    id => NonEmptyStr,
    type => Enum["audio"],
    duration => PositiveOrZeroInt,
    contentProvider => $ContentProvider,
];

# https://developers.line.biz/en/reference/messaging-api/#wh-file
my $FileMessage = declare FileMessage => as Dict[
    id => NonEmptyStr,
    type => Enum["file"],
    fileName => NonEmptyStr,
    fileSize => PositiveOrZeroInt,
];

# https://developers.line.biz/en/reference/messaging-api/#wh-location
my $LocationMessage = declare LocationMessage => as Dict[
    id => NonEmptyStr,
    type => Enum["location"],
    title => NonEmptyStr,
    address => NonEmptyStr,
    latitude => Num,
    longtitude => Num,
];

# https://developers.line.biz/en/reference/messaging-api/#wh-sticker
my $StickerMessage = declare StickerMessage => as Dict[
    id => NonEmptyStr,
    type => Enum["sticker"],
    packageId => NonEmptyStr,
    stickerId => NonEmptyStr,
];

# https://developers.line.biz/en/reference/messaging-api/#message-event
declare MessageEvent => as Dict[
    type => Enum["message"],
    replyToken => NonEmptyStr,
    timestamp => PositiveOrZeroNum,
    message => $TextMessage | $ImageMessage | $AudioMessage | $FileMessage | $LocationMessage | $StickerMessage,
];

__PACKAGE__->meta->make_immutable;
1;