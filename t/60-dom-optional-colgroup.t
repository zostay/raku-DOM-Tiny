#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "colgroup" tag
my $dom = DOM::Tiny.parse(q:to/EOF/);
<table>
  <col id=morefail>
  <col id=fail>
  <colgroup>
    <col id=foo>
    <col class=foo>
  <colgroup>
    <col id=bar>
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

done-testing;
