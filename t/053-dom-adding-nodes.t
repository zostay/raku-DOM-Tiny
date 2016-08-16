#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Adding nodes
my $dom = DOM::Tiny.parse(q:to/EOF/);
<ul>
    <li>A</li>
    <p>B</p>
    <li>C</li>
</ul>
<div>D</div>
EOF
$dom.at('li').append('<p>A1</p>23');
is "$dom", q:to/EOF/, 'right result';
<ul>
    <li>A</li><p>A1</p>23
    <p>B</p>
    <li>C</li>
</ul>
<div>D</div>
EOF
$dom.at('li').prepend('24').prepend('<div>A-1</div>25');
is "$dom", q:to/EOF/, 'right result';
<ul>
    24<div>A-1</div>25<li>A</li><p>A1</p>23
    <p>B</p>
    <li>C</li>
</ul>
<div>D</div>
EOF
is $dom.at('div').text, 'A-1', 'right text';
is $dom.at('iv'), Nil, 'no result';
is $dom.prepend('l').prepend('alal').prepend('a').type, Root,
  'right type';
is "$dom", q:to/EOF/, 'no changes';
<ul>
    24<div>A-1</div>25<li>A</li><p>A1</p>23
    <p>B</p>
    <li>C</li>
</ul>
<div>D</div>
EOF
is $dom.append('lalala').type, Root, 'right type';
is "$dom", q:to/EOF/, 'no changes';
<ul>
    24<div>A-1</div>25<li>A</li><p>A1</p>23
    <p>B</p>
    <li>C</li>
</ul>
<div>D</div>
EOF
$dom.find('div').map({ .append('works') });
is "$dom", q:to/EOF/, 'right result';
<ul>
    24<div>A-1</div>works25<li>A</li><p>A1</p>23
    <p>B</p>
    <li>C</li>
</ul>
<div>D</div>works
EOF
$dom.at('li').prepend-content('A3<p>A2</p>').prepend-content('A4');
is $dom.at('li').text, 'A4A3 A', 'right text';
is "$dom", q:to/EOF/, 'right result';
<ul>
    24<div>A-1</div>works25<li>A4A3<p>A2</p>A</li><p>A1</p>23
    <p>B</p>
    <li>C</li>
</ul>
<div>D</div>works
EOF
$dom.find('li').[1].append-content('<p>C2</p>C3').append-content(' C4')\
  .append-content('C5');
is $dom.find('li').[1].text, 'C C3 C4C5', 'right text';
is "$dom", q:to/EOF/, 'right result';
<ul>
    24<div>A-1</div>works25<li>A4A3<p>A2</p>A</li><p>A1</p>23
    <p>B</p>
    <li>C<p>C2</p>C3 C4C5</li>
</ul>
<div>D</div>works
EOF

done-testing;
