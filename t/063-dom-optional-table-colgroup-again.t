#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "colgroup", "tbody", "tr", "th" and "td" tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<table>
  <colgroup>
    <col id=foo />
    <col class=foo>
  <colgroup>
    <col id=bar>
  </colgroup>
  <tbody>
    <tr>
      <td>B
</table>
EOF
is $dom.find('table > colgroup > col').[0].attr<id>, 'foo',
  'right attribute';
is $dom.find('table > colgroup > col').[1].attr<class>, 'foo',
  'right attribute';
is $dom.find('table > colgroup > col').[2].attr<id>, 'bar',
  'right attribute';
is $dom.at('table > tbody > tr > td').text(:trim), 'B', 'right text';

done-testing;
