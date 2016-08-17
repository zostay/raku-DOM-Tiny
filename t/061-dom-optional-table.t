#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "thead", "tbody", "tfoot", "tr", "th" and "td" tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<table>
  <thead>
    <tr>
      <th>A</th>
      <th>D
  <tfoot>
    <tr>
      <td>C
  <tbody>
    <tr>
      <td>B
</table>
EOF
is $dom.at('table > thead > tr > th').text, 'A', 'right text';
is $dom.find('table > thead > tr > th').[1].text(:trim), 'D', 'right text';
is $dom.at('table > tbody > tr > td').text(:trim), 'B', 'right text';
is $dom.at('table > tfoot > tr > td').text(:trim), 'C', 'right text';

done-testing;
