#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "optgroup" and "option" tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<div>
  <optgroup>A
    <option id="foo">B
    <option>C</option>
    <option>D
  <OPTGROUP>E
    <option>F
  <optgroup>G
    <option>H
</div>
EOF
is $dom.find('div > optgroup').[0].text(:trim),          'A', 'right text';
is $dom.find('div > optgroup > #foo').[0].text(:trim),   'B', 'right text';
is $dom.find('div > optgroup > option').[1].text, 'C', 'right text';
is $dom.find('div > optgroup > option').[2].text(:trim), 'D', 'right text';
is $dom.find('div > optgroup').[1].text(:trim),          'E', 'right text';
is $dom.find('div > optgroup > option').[3].text(:trim), 'F', 'right text';
is $dom.find('div > optgroup').[2].text(:trim),          'G', 'right text';
is $dom.find('div > optgroup > option').[4].text(:trim), 'H', 'right text';

done-testing;
