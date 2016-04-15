package ExampleBot::Dispatcher;
use strict;
use warnings;

use LINEBotFramework::Dispatcher ':DSL';

sub dispatch {
    if (is_text) {
        if (context_is 'memo_mode') {
            if (session->{memo}{expire_at} < time()) {
                return +{
                    text         => 'memo mode session is expired.',
                    next_context => 'default',
                };
            }

            if ($_ eq '@end') {
                return 'Memo#finish';
            } else {
                return 'Memo#add';
            }
        }

        if (/^(?:help|lost|forget)$/i) {
            return +{
                page          => 'help',
                template_vars => { app_name => 'example bot' },
            };
        } elsif (/memo/) {
            session->{memo} = +{
                stack     => [],
                expire_at => time() + 60,
            };
            return +{
                page => 'memo',
                next_context => 'memo_mode',
            };
        }
    }
}
1;
