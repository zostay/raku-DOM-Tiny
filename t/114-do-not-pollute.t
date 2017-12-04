use v6;

use Test;

plan 4;

lives-ok {
    use DOM::Tiny;
    class Text { }
    ok DOM::Tiny::HTML::Text.perl, 'we can get to Text as a thing with the long name';
}

lives-ok {
    use DOM::Tiny;
    use DOM::Tiny::HTML;
    ok Text.perl, 'we can get Text as a thing too';
}
