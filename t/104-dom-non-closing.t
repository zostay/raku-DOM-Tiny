#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Not self-closing
my $dom = DOM::Tiny.parse('<div />< div ><pre />test</div >123');
is $dom.at('div > div > pre').text, 'test', 'right text';
is "$dom", '<div><div><pre>test</pre></div>123</div>', 'right result';
$dom = DOM::Tiny.parse('<p /><svg><circle /><circle /></svg>');
is $dom.find('p > svg > circle').elems, 2, 'two circles';
is "$dom", '<p><svg><circle></circle><circle></circle></svg></p>',
  'right result';

done-testing;
