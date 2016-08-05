#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Empty attributes
my $dom = DOM::Tiny.parse(qq{<div test="" test2='' />});
is $dom.at('div').attr<test>,  '', 'empty attribute value';
is $dom.at('div').attr<test2>, '', 'empty attribute value';
is $dom.at('[test]').tag,  'div', 'right tag';
is $dom.at('[test2]').tag, 'div', 'right tag';
is $dom.at('[test3]'), Nil, 'no result';
is $dom.at('[test=""]').tag,  'div', 'right tag';
is $dom.at('[test2=""]').tag, 'div', 'right tag';
is $dom.at('[test3=""]'), Nil, 'no result';

done-testing;
