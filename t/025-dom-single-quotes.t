#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# HTML1 (single quotes, uppercase tags and whitespace in attributes)
my $dom = DOM::Tiny.parse(q{<DIV id = 'test' foo ='bar' class= "tset">works</DIV>});
is $dom.at('#test').text,       'works', 'right text';
is $dom.at('div').text,         'works', 'right text';
is $dom.at('[foo="bar"]').text, 'works', 'right text';
is $dom.at('[foo="ba"]'), Nil, 'no result';
is $dom.at('[foo=bar]').text, 'works', 'right text';
is $dom.at('[foo=ba]'), Nil, 'no result';
is $dom.at('.tset').text, 'works', 'right text';

done-testing;
