#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# "0"
my $dom = DOM::Tiny.parse('0');
is "$dom", '0', 'right result';
$dom.append-content('☃');
is "$dom", '0☃', 'right result';
is $dom.parse('<!DOCTYPE 0>'),  '<!DOCTYPE 0>',  'successful roundtrip';
is $dom.parse('<!--0-->'),      '<!--0-->',      'successful roundtrip';
is $dom.parse('<![CDATA[0]]>'), '<![CDATA[0]]>', 'successful roundtrip';
is $dom.parse('<?0?>'),         '<?0?>',         'successful roundtrip';

done-testing;
