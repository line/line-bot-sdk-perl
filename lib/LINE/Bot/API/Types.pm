package LINE::Bot::API::Types;
use strict;
use warnings;

use Type::Library -base;
use Type::Utils -all;
use Types::Standard qw<Str Int Num Bool Dict Enum Optional ArrayRef HashRef>;
use Types::Common::Numeric qw< PositiveOrZeroInt PositiveOrZeroNum >;
use Types::Common::String qw< StrLength NonEmptyStr >;

# https://developers.line.biz/en/reference/messaging-api/#source-user
my $SourceUser = declare SourceUser => as Dict[
    type    => Enum["user"],
    userId  => NonEmptyStr,
];

# https://developers.line.biz/en/reference/messaging-api/#source-group
my $SourceGroup = declare SourceGroup => as Dict[
    type    => Enum["group"],
    groupId => NonEmptyStr,
    userId   => Optional[Str],
];

# https://developers.line.biz/en/reference/messaging-api/#source-room
my $SourceRoom = declare SourceRoom => as Dict[
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
    source  => $SourceGroup | $SourceUser | $SourceRoom,
    message => $TextMessage | $ImageMessage | $AudioMessage | $VideoMessage | $FileMessage | $LocationMessage | $StickerMessage,
];

# https://developers.line.biz/en/reference/messaging-api/#error-responses
declare ErrorResponse => as Dict[
    message => NonEmptyStr,
    details => ArrayRef[
        Dict[
            message  => NonEmptyStr,
            property => NonEmptyStr,
        ]
    ]
];

my @__common__ = (
    timestamp  => PositiveOrZeroNum,
    source     => $SourceGroup | $SourceUser | $SourceRoom,
);

# https://developers.line.biz/en/reference/messaging-api/#follow-event
declare FollowEvent => as Dict[
    type       => Enum["follow"],
    replyToken => NonEmptyStr,
    @__common__
];

# https://developers.line.biz/en/reference/messaging-api/#unfollow-event
declare UnfollowEvent => as Dict[
    type       => Enum["unfollow"],
    @__common__
];

# https://developers.line.biz/en/reference/messaging-api/#join-event
declare JoinEvent => as Dict[
    type       => Enum["join"],
    replyToken => NonEmptyStr,
    @__common__,
];

# https://developers.line.biz/en/reference/messaging-api/#leave-event
declare LeaveEvent => as Dict[
    type       => Enum["leave"],
    @__common__,
];

# https://developers.line.biz/en/reference/messaging-api/#member-joined-event
declare MemberJoinedEvent => as Dict[
    type       => Enum["memberJoined"],
    replyToken => NonEmptyStr,
    joined     => Dict[
        members => ArrayRef[ $SourceUser ]
    ],
    @__common__,
];

# https://developers.line.biz/en/reference/messaging-api/#member-left-event
declare MemberLeftEvent => as Dict[
    type       => Enum["memberLeft"],
    left       => Dict[
        members => ArrayRef[ $SourceUser ]
    ],
    @__common__,
];

# https://developers.line.biz/en/reference/messaging-api/#postback-event
declare PostbackEvent => as Dict[
    type       => Enum["postback"],
    replyToken => NonEmptyStr,
    postback   => Dict[
        data => Str,
        params => HashRef
    ],
    @__common__,
];

# https://developers.line.biz/en/reference/messaging-api/#beacon-event
declare BeaconEvent => as Dict[
    type       => Enum["beacon"],
    replyToken => NonEmptyStr,
    beacon     => Dict[
        hwid => NonEmptyStr,
        type => Enum["enter", "leave", "banner"],
        dm   => Optional[Str],
    ],
    @__common__,
];

# https://developers.line.biz/en/reference/messaging-api/#account-link-event
declare AccountLinkEvent => as Dict[
    type       => Enum["accountLink"],
    replyToken => NonEmptyStr,
    link       => Dict[
        result => Enum["ok", "failed"],
        nonce  => Str
    ],
    @__common__,
];

# https://developers.line.biz/en/reference/messaging-api/#device-link-event
declare DeviceLinkEvent => as Dict[
    type       => Enum["things"],
    replyToken => NonEmptyStr,
    things     => Dict[
        type => Enum["link"],
        deviceId => NonEmptyStr,
    ],
    @__common__,
];

# https://developers.line.biz/en/reference/messaging-api/#device-unlink-event
declare DeviceUnlinkEvent => as Dict[
    type       => Enum["things"],
    replyToken => NonEmptyStr,
    things     => Dict[
        type => Enum["unlink"],
        deviceId => NonEmptyStr,
    ],
    @__common__,
];

1;
