#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Unusual order
my $dom = DOM::Tiny.parse('<a href="http://example.com" id="foo" class="bar">Ok!</a>');
is $dom.at('a:not([href$=foo])[href^=h]').text, 'Ok!', 'right text';
is $dom.at('a:not([href$=example.com])[href^=h]'), Nil, 'no result';
is $dom.at('a[href^=h]#foo.bar').text, 'Ok!', 'right text';
is $dom.at('a[href^=h]#foo.baz'), Nil, 'no result';
is $dom.at('a[href^=h]#foo:not(b)').text, 'Ok!', 'right text';
is $dom.at('a[href^=h]#foo:not(a)'), Nil, 'no result';
is $dom.at('[href^=h].bar:not(b)[href$=m]#foo').text, 'Ok!', 'right text';
is $dom.at('[href^=h].bar:not(b)[href$=m]#bar'), Nil, 'no result';
is $dom.at(':not(b)#foo#foo').text, 'Ok!', 'right text';
is $dom.at(':not(b)#foo#bar'), Nil, 'no result';
is $dom.at(':not([href^=h]#foo#bar)').text, 'Ok!', 'right text';
is $dom.at(':not([href^=h]#foo#foo)'), Nil, 'no result';

done-testing;
