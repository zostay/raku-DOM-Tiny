#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "dt" and "dd" tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<dl>
  <dt>A</dt>
  <DD>B
  <dt>C</dt>
  <dd>D
  <dt>E
  <dd>F
</dl>
EOF
is $dom.find('dl > dt').[0].text, 'A', 'right text';
is $dom.find('dl > dd').[0].text(:trim), 'B', 'right text';
is $dom.find('dl > dt').[1].text, 'C', 'right text';
is $dom.find('dl > dd').[1].text(:trim), 'D', 'right text';
is $dom.find('dl > dt').[2].text(:trim), 'E', 'right text';
is $dom.find('dl > dd').[2].text(:trim), 'F', 'right text';

done-testing;
