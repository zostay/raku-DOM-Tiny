#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Comments
my $dom = DOM::Tiny.parse(q:to/EOF/);
<!-- HTML5 -->
<!-- bad idea -- HTML5 -->
<!-- HTML4 -- >
<!-- bad idea -- HTML4 -- >
EOF
is $dom.tree.children[0].comment, ' HTML5 ',             'right comment';
is $dom.tree.children[2].comment, ' bad idea -- HTML5 ', 'right comment';
is $dom.tree.children[4].comment, ' HTML4 ',             'right comment';
is $dom.tree.children[6].comment, ' bad idea -- HTML4 ', 'right comment';

done-testing;
