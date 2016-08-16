#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Append and prepend content
my $dom = DOM::Tiny.parse('<a><b>Test<c /></b></a>');
$dom.at('b').append-content('<d />');
is $dom.children.[0].tag, 'a', 'right tag';
is $dom.all-text, 'Test', 'right text';
is $dom.at('c').parent.tag, 'b', 'right tag';
is $dom.at('d').parent.tag, 'b', 'right tag';
$dom.at('b').prepend-content('<e>DOM</e>');
is $dom.at('e').parent.tag, 'b', 'right tag';
is $dom.all-text, 'DOM Test', 'right text';

done-testing;
