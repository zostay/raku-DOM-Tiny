#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Class with hyphen
my $dom = DOM::Tiny.parse('<div class="a">A</div><div class="a-1">A1</div>');
my @div = $dom.find('.a').map({ .text });
is-deeply @div, ['A'], 'found first element only';
@div = $dom.find('.a-1').map({ .text });
is-deeply @div, ['A1'], 'found last element only';

done-testing;
