#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Multiple attributes
my $dom = DOM::Tiny.parse(q:to/EOF/);
<div foo="bar" bar="baz">A</div>
<div foo="bar">B</div>
<div foo="bar" bar="baz">C</div>
<div foo="baz" bar="baz">D</div>
EOF
my @div = $dom.find('div[foo="bar"][bar="baz"]').map({ .text });
is-deeply @div, <A C>.Array, 'found all div elements with the right atributes';
@div = $dom.find('div[foo^="b"][foo$="r"]').map({ .text });
is-deeply @div, <A B C>.Array, 'found all div elements with the right atributes';
is $dom.at('[foo="bar"]').previous, Nil, 'no previous sibling';
is $dom.at('[foo="bar"]').next.text, 'B', 'right text';
is $dom.at('[foo="bar"]').next.previous.text, 'A', 'right text';
is $dom.at('[foo="bar"]').next.next.next.next, Nil, 'no next sibling';

done-testing;
