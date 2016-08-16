#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.parse(
    q[<foo><bar a="b&lt;c">ju<baz a23>s<bazz />t</bar>works</foo>],
);
cmp-ok $dom.tree, '~~', Root, 'right type';
cmp-ok $dom.tree.children[0], '~~', Tag, 'right type';
is $dom.tree.children[0].tag, 'foo', 'right tag';
is-deeply $dom.tree.children[0].attr, {}, 'empty attributes';
cmp-ok $dom.tree.children[0].parent, '===', $dom.tree, 'right parent';
cmp-ok $dom.tree.children[0].children[0], '~~', Tag, 'right type';
is $dom.tree.children[0].children[0].tag, 'bar', 'right tag';
is-deeply $dom.tree.children[0].children[0].attr, {a => 'b<c'}, 'right attributes';
cmp-ok $dom.tree.children[0].children[0].parent, '===', $dom.tree.children[0], 'right parent';
cmp-ok $dom.tree.children[0].children[0].children[0], '~~', Text, 'right type';
is $dom.tree.children[0].children[0].children[0].text, 'ju',   'right text';
cmp-ok $dom.tree.children[0].children[0].children[0].parent, '===', $dom.tree.children[0].children[0], 'right parent';
cmp-ok $dom.tree.children[0].children[0].children[1], '~~', Tag, 'right type';
is $dom.tree.children[0].children[0].children[1].tag, 'baz', 'right tag';
is-deeply $dom.tree.children[0].children[0].children[1].attr, {a23 => Nil}, 'right attributes';
cmp-ok $dom.tree.children[0].children[0].children[1].parent, '===', $dom.tree.children[0].children[0], 'right parent';
cmp-ok $dom.tree.children[0].children[0].children[1].children[0], '~~', Text, 'right type';
is $dom.tree.children[0].children[0].children[1].children[0].text, 's',    'right text';
cmp-ok $dom.tree.children[0].children[0].children[1].children[0].parent, '===', $dom.tree.children[0].children[0].children[1], 'right parent';
cmp-ok $dom.tree.children[0].children[0].children[1].children[1], '~~', Tag,  'right type';
is $dom.tree.children[0].children[0].children[1].children[1].tag, 'bazz', 'right tag';
is-deeply $dom.tree.children[0].children[0].children[1].children[1].attr, {}, 'empty attributes';
cmp-ok $dom.tree.children[0].children[0].children[1].children[1].parent, '===', $dom.tree.children[0].children[0].children[1], 'right parent';
cmp-ok $dom.tree.children[0].children[0].children[1].children[2], '~~', Text, 'right type';
is $dom.tree.children[0].children[0].children[1].children[2].text, 't',    'right text';
cmp-ok $dom.tree.children[0].children[0].children[1].children[2].parent, '===', $dom.tree.children[0].children[0].children[1], 'right parent';
cmp-ok $dom.tree.children[0].children[1], '~~', Text, 'right type';
is $dom.tree.children[0].children[1].text, 'works', 'right text';
cmp-ok $dom.tree.children[0].children[1].parent, '===', $dom.tree.children[0], 'right parent';
is $dom.render, q:to/EOF/.trim, 'right result';
<foo><bar a="b&lt;c">ju<baz a23>s<bazz></bazz>t</baz></bar>works</foo>
EOF

done-testing;
