#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Empty attribute value
my $dom = DOM::Tiny.parse(q:to/EOF/);
<foo bar=>
  test
</foo>
<bar>after</bar>
EOF
is $dom.tree.WHAT, Root, 'right type';
is $dom.tree.children[0].WHAT, Tag, 'right type';
is $dom.tree.children[0].tag, 'foo', 'right tag';
is-deeply $dom.tree.children[0].attr, {bar => ''}, 'right attributes';
is $dom.tree.children.[0].children[0].WHAT, Text,       'right type';
is $dom.tree.children[0].children[0].text, "\n  test\n", 'right text';
is $dom.tree.children[2].WHAT, Tag, 'right type';
is $dom.tree.children[2].tag, 'bar', 'right tag';
is $dom.tree.children[2].children[0].WHAT, Text,  'right type';
is $dom.tree.children[2].children[0].text, 'after', 'right text';
is "$dom", q:to/EOF/, 'right result';
<foo bar="">
  test
</foo>
<bar>after</bar>
EOF

done-testing;
