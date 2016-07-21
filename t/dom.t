#!/usr/bin/env perl6
use v6;

use Test;
use Mojo::DOM;

my $dom = Mojo::DOM.parse(
    q[<foo><bar a="b&lt;c">ju<baz a23>s<bazz />t</bar>works</foo>],
);
#dd $dom;
is $dom.tree[0], Root, 'right type';
is $dom.tree[1][0], Tag, 'right type';
is $dom.tree[1][1], 'foo', 'right tag';
is-deeply $dom.tree[1][2], {}, 'empty attributes';
cmp-ok $dom.tree[1][3], '===', $dom.tree, 'right parent';
is $dom.tree[1][4][0], Tag, 'right type';
is $dom.tree[1][4][1], 'bar', 'right tag';
is-deeply $dom.tree[1][4][2], {a => 'b<c'}, 'right attributes';
cmp-ok $dom.tree[1][4][3], '===', $dom.tree[1], 'right parent';
is $dom.tree[1][4][4][0], Text, 'right type';
is $dom.tree[1][4][4][1], 'ju',   'right text';
cmp-ok $dom.tree[1][4][4][2], '===', $dom.tree[1][4], 'right parent';
is $dom.tree[1][4][5][0], Tag, 'right type';
is $dom.tree[1][4][5][1], 'baz', 'right tag';
is-deeply $dom.tree[1][4][5][2], {a23 => Nil}, 'right attributes';
cmp-ok $dom.tree[1][4][5][3], '===', $dom.tree[1][4], 'right parent';
is $dom.tree[1][4][5][4][0], Text, 'right type';
is $dom.tree[1][4][5][4][1], 's',    'right text';
cmp-ok $dom.tree[1][4][5][4][2], '===', $dom.tree[1][4][5], 'right parent';
is $dom.tree[1][4][5][5][0], Tag,  'right type';
is $dom.tree[1][4][5][5][1], 'bazz', 'right tag';
is-deeply $dom.tree[1][4][5][5][2], {}, 'empty attributes';
cmp-ok $dom.tree[1][4][5][5][3], '===', $dom.tree[1][4][5], 'right parent';
is $dom.tree[1][4][5][6][0], Text, 'right type';
is $dom.tree[1][4][5][6][1], 't',    'right text';
cmp-ok $dom.tree[1][4][5][6][2], '===', $dom.tree[1][4][5], 'right parent';
is $dom.tree[1][5][0], Text,  'right type';
is $dom.tree[1][5][1], 'works', 'right text';
cmp-ok $dom.tree[1][5][2], '===', $dom.tree[1], 'right parent';
is $dom.render, q:to/EOF/.trim, 'right result';
<foo><bar a="b&lt;c">ju<baz a23>s<bazz></bazz>t</baz></bar>works</foo>
EOF

#say $dom;

done-testing;
