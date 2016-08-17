#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Nested description lists
my $dom = DOM::Tiny.parse(q:to/EOF/);
<dl>
  <dt>A</dt>
  <DD>
    <dl>
      <dt>B
      <dd>C
    </dl>
  </dd>
</dl>
EOF
is $dom.find('dl > dd > dl > dt').[0].text(:trim), 'B', 'right text';
is $dom.find('dl > dd > dl > dd').[0].text(:trim), 'C', 'right text';
is $dom.find('dl > dt').[0].text,           'A', 'right text';

done-testing;
