#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Extra whitespace
my $dom = DOM::Tiny.parse('< span>a< /span><b >b</b><span >c</ span>');
is $dom.at('span').text,     'a', 'right text';
is $dom.at('span + b').text, 'b', 'right text';
is $dom.at('b + span').text, 'c', 'right text';
is "$dom", '<span>a</span><b>b</b><span>c</span>', 'right result';

done-testing;
