#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Multi-line attribute
my $dom = DOM::Tiny.parse(qq{<div class="line1\nline2" />});
is $dom.at('div').attr<class>, "line1\nline2", 'multi-line attribute value';
is $dom.at('.line1').tag, 'div', 'right tag';
is $dom.at('.line2').tag, 'div', 'right tag';
is $dom.at('.line3'), Nil, 'no result';

done-testing;
