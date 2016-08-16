#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Result and iterator order
my $dom = DOM::Tiny.parse('<a><b>1</b></a><b>2</b><b>3</b>');
my @numbers = $dom.find('b').kv.map(-> $i, $v { $i+1, $v.text.Int }).flat;
is-deeply @numbers, [1, 1, 2, 2, 3, 3], 'right order';

done-testing;
