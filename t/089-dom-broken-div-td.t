#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Broken "div" in "td"
my $dom = DOM::Tiny.parse(q:to/EOF/);
<table>
  <tr>
    <td><div id="A"></td>
    <td><div id="B"></td>
  </tr>
</table>
EOF
is $dom.find('table tr td').[0].at('div')<id>, 'A', 'right attribute';
is $dom.find('table tr td').[1].at('div')<id>, 'B', 'right attribute';
is $dom.find('table tr td').[2], Nil, 'no result';
is $dom.find('table tr td').elems, 2, 'right number of elements';
is "$dom", q:to/EOF/, 'right result';
<table>
  <tr>
    <td><div id="A"></div></td>
    <td><div id="B"></div></td>
  </tr>
</table>
EOF

done-testing;
