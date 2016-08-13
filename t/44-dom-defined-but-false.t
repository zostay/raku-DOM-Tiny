#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# TODO probably a totally unnecessary test in Perl 6

# Defined but false text
my $dom = DOM::Tiny.parse(
  '<div><div id="a">A</div><div id="b">B</div></div><div id="0">0</div>');
my @div = $dom.find('div[id]').map({ .text });
is-deeply @div, ['A', 'B', '0'], 'found all div elements with id';

done-testing;
