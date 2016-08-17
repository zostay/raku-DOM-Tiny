#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Dot and hash in class and id attributes
my $dom = DOM::Tiny.parse('<p class="a#b.c">A</p><p id="a#b.c">B</p>');
is $dom.at('p.a\#b\.c').text,       'A', 'right text';
is $dom.at(':not(p.a\#b\.c)').text, 'B', 'right text';
is $dom.at('p#a\#b\.c').text,       'B', 'right text';
is $dom.at(':not(p#a\#b\.c)').text, 'A', 'right text';

done-testing;
