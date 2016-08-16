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
is $dom.find('ruby > rt').[0].text, 'B', 'right text';
is $dom.find('ruby > rp').[1].text, 'C', 'right text';
is $dom.find('ruby > rt').[1].text, 'D', 'right text';
is $dom.find('ruby > rp').[2].text, 'E', 'right text';
is $dom.find('ruby > rt').[2].text, 'F', 'right text';

done-testing;
