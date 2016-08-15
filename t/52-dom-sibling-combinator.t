#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Sibling combinator
my $dom = DOM::Tiny.parse(q:to/EOF/);
<ul>
    <li>A</li>
    <p>B</p>
    <li>C</li>
</ul>
<h1>D</h1>
<p id="♥">E</p>
<p id="☃">F<b>H</b></p>
<div>G</div>
EOF
is $dom.at('li ~ p').text,       'B', 'right text';
is $dom.at('li + p').text,       'B', 'right text';
is $dom.at('h1 ~ p ~ p').text,   'F', 'right text';
is $dom.at('h1 + p ~ p').text,   'F', 'right text';
is $dom.at('h1 ~ p + p').text,   'F', 'right text';
is $dom.at('h1 + p + p').text,   'F', 'right text';
is $dom.at('h1  +  p+p').text,   'F', 'right text';
is $dom.at('ul > li ~ li').text, 'C', 'right text';
is $dom.at('ul li ~ li').text,   'C', 'right text';
is $dom.at('ul>li~li').text,     'C', 'right text';
is $dom.at('ul li li'),     Nil, 'no result';
is $dom.at('ul ~ li ~ li'), Nil, 'no result';
is $dom.at('ul + li ~ li'), Nil, 'no result';
is $dom.at('ul > li + li'), Nil, 'no result';
is $dom.at('h1 ~ div').text, 'G', 'right text';
is $dom.at('h1 + div'), Nil, 'no result';
is $dom.at('p + div').text,               'G', 'right text';
is $dom.at('ul + h1 + p + p + div').text, 'G', 'right text';
is $dom.at('ul + h1 ~ p + div').text,     'G', 'right text';
is $dom.at('h1 ~ #♥').text,             'E', 'right text';
is $dom.at('h1 + #♥').text,             'E', 'right text';
is $dom.at('#♥~#☃').text,             'F', 'right text';
is $dom.at('#♥+#☃').text,             'F', 'right text';
is $dom.at('#♥+#☃>b').text,           'H', 'right text';
is $dom.at('#♥ > #☃'), Nil, 'no result';
is $dom.at('#♥ #☃'),   Nil, 'no result';
is $dom.at('#♥ + #☃ + :nth-last-child(1)').text,  'G', 'right text';
is $dom.at('#♥ ~ #☃ + :nth-last-child(1)').text,  'G', 'right text';
is $dom.at('#♥ + #☃ ~ :nth-last-child(1)').text,  'G', 'right text';
is $dom.at('#♥ ~ #☃ ~ :nth-last-child(1)').text,  'G', 'right text';
is $dom.at('#♥ + :nth-last-child(2)').text,         'F', 'right text';
is $dom.at('#♥ ~ :nth-last-child(2)').text,         'F', 'right text';
is $dom.at('#♥ + #☃ + *:nth-last-child(1)').text, 'G', 'right text';
is $dom.at('#♥ ~ #☃ + *:nth-last-child(1)').text, 'G', 'right text';
is $dom.at('#♥ + #☃ ~ *:nth-last-child(1)').text, 'G', 'right text';
is $dom.at('#♥ ~ #☃ ~ *:nth-last-child(1)').text, 'G', 'right text';
is $dom.at('#♥ + *:nth-last-child(2)').text,        'F', 'right text';
is $dom.at('#♥ ~ *:nth-last-child(2)').text,        'F', 'right text';

done-testing;
