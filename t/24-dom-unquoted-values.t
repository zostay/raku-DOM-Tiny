#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# HTML5 (unquoted values)
my $dom = DOM::Tiny.parse(
  '<div id = test foo ="bar" class=tset bar=/baz/ baz=//>works</div>');
is $dom.at('#test').text,                'works', 'right text';
is $dom.at('div').text,                  'works', 'right text';
is $dom.at('[foo=bar][foo="bar"]').text, 'works', 'right text';
is $dom.at('[foo="ba"]'), Nil, 'no result';
is $dom.at('[foo=bar]').text, 'works', 'right text';
is $dom.at('[foo=ba]'), Nil, 'no result';
is $dom.at('.tset').text,       'works', 'right text';
is $dom.at('[bar=/baz/]').text, 'works', 'right text';
is $dom.at('[baz=//]').text,    'works', 'right text';

done-testing;
