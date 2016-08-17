#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "p" tag
my $dom = DOM::Tiny.parse(q:to/EOF/);
<div>
  <p>A</p>
  <P>B
  <p>C</p>
  <p>D<div>X</div>
  <p>E<img src="foo.png">
  <p>F<br>G
  <p>H
</div>
EOF
is $dom.find('div > p').[0].text, 'A',   'right text';
is $dom.find('div > p').[1].text(:trim), 'B',   'right text';
is $dom.find('div > p').[2].text, 'C',   'right text';
is $dom.find('div > p').[3].text, 'D',   'right text';
is $dom.find('div > p').[4].text(:trim), 'E',   'right text';
is $dom.find('div > p').[5].text(:trim), 'F G', 'right text';
is $dom.find('div > p').[6].text(:trim), 'H',   'right text';
is $dom.find('div > p > p').[0], Nil, 'no results';
is $dom.at('div > p > img').attr<src>, 'foo.png', 'right attribute';
is $dom.at('div > div').text, 'X', 'right text';

done-testing;
