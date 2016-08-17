#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "colgroup", "thead", "tbody", "tr", "th" and "td" tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<table>
  <col id=morefail>
  <col id=fail>
  <colgroup>
    <col id=foo />
    <col class=foo>
  <colgroup>
    <col id=bar>
  </colgroup>
  <thead>
    <tr>
      <th>A</th>
      <th>D
  <tbody>
    <tr>
      <td>B
  <tbody>
    <tr>
      <td>E
</table>
EOF
is $dom.find('table > col').[0].attr<id>, 'morefail', 'right attribute';
is $dom.find('table > col').[1].attr<id>, 'fail',     'right attribute';
is $dom.find('table > colgroup > col').[0].attr<id>, 'foo',
  'right attribute';
is $dom.find('table > colgroup > col').[1].attr<class>, 'foo',
  'right attribute';
is $dom.find('table > colgroup > col').[2].attr<id>, 'bar',
  'right attribute';
is $dom.at('table > thead > tr > th').text, 'A', 'right text';
is $dom.find('table > thead > tr > th').[1].text(:trim), 'D', 'right text';
is $dom.at('table > tbody > tr > td').text(:trim), 'B', 'right text';
is $dom.find('table > tbody > tr > td').map({ .text(:trim) }).join("\n"), "B\nE",
  'right text';

done-testing;
