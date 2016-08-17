#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "tr" and "td" tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<table>
    <tr>
      <td>A
      <td>B</td>
    <tr>
      <td>C
    </tr>
    <tr>
      <td>D
</table>
EOF
is $dom.find('table > tr > td').[0].text(:trim), 'A', 'right text';
is $dom.find('table > tr > td').[1].text, 'B', 'right text';
is $dom.find('table > tr > td').[2].text(:trim), 'C', 'right text';
is $dom.find('table > tr > td').[3].text(:trim), 'D', 'right text';

done-testing;
