subtest upload_rich_menu_image => sub {
    my $contentType = 'image/jpeg';
    my $imagePath = './controller-rich-menu-image-sample.jpeg';

    send_request {
        my $res = $bot->upload_rich_menu_image('DUMMY_RICH_MENU_ID', $contentType, $imagePath);
        ok $res->is_success;
        is $res->http_status, 200;
    } receive_request {
        my %args = @_;
        is $args{method}, 'POST';
        is $args{url},    'https://api.line.me/v2/bot/richmenu/DUMMY_RICH_MENU_ID/content';

        my %headers = @{ $args{headers} };
        is $headers{'content-type'}, 'image/jpeg';

        +{};
    }
}