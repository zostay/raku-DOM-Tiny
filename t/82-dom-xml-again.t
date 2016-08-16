#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Ensure XML semantics again
my $dom = DOM::Tiny.parse(q:to/EOF/, :xml);
<table>
  <td>
    <tr><thead>foo<thead></tr>
  </td>
  <td>
    <tr><thead>bar<thead></tr>
  </td>
</table>
EOF
is $dom.find('table > td > tr > thead').[0].text, 'foo', 'right text';
is $dom.find('table > td > tr > thead').[1].text, 'bar', 'right text';
is $dom.find('table > td > tr > thead').[2], Nil, 'no result';
is $dom.find('table > td > tr > thead').elems, 2, 'right number of elements';

done-testing;
