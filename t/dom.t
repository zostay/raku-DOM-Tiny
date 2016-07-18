#!/usr/bin/env perl6
use v6;

use Test;
use Mojo::DOM::HTML;

my $dom = Mojo::DOM::HTML::Tokenizer.parse(
    q[<foo><bar a="b&lt;c">ju<baz a23>s<bazz />t</bar>works</foo>],
    actions => Mojo::DOM::HTML::TreeMaker.new,
).made;
#dd $dom;
is $dom[0], Mojo::DOM::HTML::Root, 'right type';
is $dom[1][0], Mojo::DOM::HTML::Tag, 'right type';
is $dom[1][1], 'foo', 'right tag';
is-deeply $dom[1][2], {}, 'empty attributes';
cmp-ok $dom[1][3], '===', $dom, 'right parent';
is $dom[1][4][0], Mojo::DOM::HTML::Tag, 'right type';
is $dom[1][4][1], 'bar', 'right tag';
is-deeply $dom[1][4][2], {a => 'b<c'}, 'right attributes';
cmp-ok $dom[1][4][3], '===', $dom[1], 'right parent';
is $dom[1][4][4][0], Mojo::DOM::HTML::Text, 'right type';
is $dom[1][4][4][1], 'ju',   'right text';
cmp-ok $dom[1][4][4][2], '===', $dom[1][4], 'right parent';
is $dom[1][4][5][0], Mojo::DOM::HTML::Tag, 'right type';
is $dom[1][4][5][1], 'baz', 'right tag';
is-deeply $dom[1][4][5][2], {a23 => Nil}, 'right attributes';
cmp-ok $dom[1][4][5][3], '===', $dom[1][4], 'right parent';
is $dom[1][4][5][4][0], Mojo::DOM::HTML::Text, 'right type';
is $dom[1][4][5][4][1], 's',    'right text';
cmp-ok $dom[1][4][5][4][2], '===', $dom[1][4][5], 'right parent';
is $dom[1][4][5][5][0], Mojo::DOM::HTML::Tag,  'right type';
is $dom[1][4][5][5][1], 'bazz', 'right tag';
is-deeply $dom[1][4][5][5][2], {}, 'empty attributes';
cmp-ok $dom[1][4][5][5][3], '===', $dom[1][4][5], 'right parent';
is $dom[1][4][5][6][0], Mojo::DOM::HTML::Text, 'right type';
is $dom[1][4][5][6][1], 't',    'right text';
cmp-ok $dom[1][4][5][6][2], '===', $dom[1][4][5], 'right parent';
is $dom[1][5][0], Mojo::DOM::HTML::Text,  'right type';
is $dom[1][5][1], 'works', 'right text';
cmp-ok $dom[1][5][2], '===', $dom[1], 'right parent';
is Mojo::DOM::HTML::_render($dom, :!xml), q:to/EOF/.trim, 'right result';
<foo><bar a="b&lt;c">ju<baz a23>s<bazz></bazz>t</baz></bar>works</foo>
EOF

#say $dom;

done-testing;
