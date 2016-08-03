#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Mixed search and tree walk
my $dom = DOM::Tiny.parse(q:to/EOF/);
<table>
  <tr>
    <td>text1</td>
    <td>text2</td>
  </tr>
</table>
EOF
my Str @data = gather for $dom.find('table tr')».children.flat -> $td {
    take $td.tag;
    take $td.all-text;
}
is @data[0], 'td',    'right tag';
is @data[1], 'text1', 'right text';
is @data[2], 'td',    'right tag';
is @data[3], 'text2', 'right text';
is @data[4], Str,   'no tag';

done-testing;
