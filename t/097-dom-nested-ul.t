#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Nested lists
my $dom = DOM::Tiny.parse(q:to/EOF/);
<div>
  <ul>
    <li>
      A
      <ul>
        <li>B</li>
        C
      </ul>
    </li>
  </ul>
</div>
EOF
is $dom.find('div > ul > li').[0].text(:trim), 'A', 'right text';
is $dom.find('div > ul > li').[1], Nil, 'no result';
is $dom.find('div > ul li').[0].text(:trim), 'A', 'right text';
is $dom.find('div > ul li').[1].text, 'B', 'right text';
is $dom.find('div > ul li').[2], Nil, 'no result';
is $dom.find('div > ul ul').[0].text(:trim), 'C', 'right text';
is $dom.find('div > ul ul').[1], Nil, 'no result';

done-testing;
