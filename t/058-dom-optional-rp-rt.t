#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "rp" and "rt" tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<ruby>
  <rp>A</rp>
  <RT>B
  <rp>C</rp>
  <rt>D
  <rp>E
  <rt>F
</ruby>
EOF
is $dom.find('ruby > rp').[0].text, 'A', 'right text';
is $dom.find('ruby > rt').[0].text(:trim), 'B', 'right text';
is $dom.find('ruby > rp').[1].text, 'C', 'right text';
is $dom.find('ruby > rt').[1].text(:trim), 'D', 'right text';
is $dom.find('ruby > rp').[2].text(:trim), 'E', 'right text';
is $dom.find('ruby > rt').[2].text(:trim), 'F', 'right text';

done-testing;
