#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "li" tag
my $dom = DOM::Tiny.parse(q:to/EOF/);
<ul>
  <li>
    <ol>
      <li>F
      <li>G
    </ol>
  <li>A</li>
  <LI>B
  <li>C</li>
  <li>D
  <li>E
</ul>
EOF
is $dom.find('ul > li > ol > li').[0].text(:trim), 'F', 'right text';
is $dom.find('ul > li > ol > li').[1].text(:trim), 'G', 'right text';
is $dom.find('ul > li').[1].text,           'A', 'right text';
is $dom.find('ul > li').[2].text(:trim),           'B', 'right text';
is $dom.find('ul > li').[3].text,           'C', 'right text';
is $dom.find('ul > li').[4].text(:trim),           'D', 'right text';
is $dom.find('ul > li').[5].text(:trim),           'E', 'right text';

done-testing;
