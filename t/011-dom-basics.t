#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom
  = DOM::Tiny.parse('<div><div FOO="0" id="a">A</div><div id="b">B</div></div>');
is $dom.at('#b').text, 'B', 'right text';
my $div := $dom.find('div[id]')».text;
is-deeply $div, <A B>, 'found all div elements with id';
is $dom.at('#a').attr('foo'), 0, 'right attribute';
is $dom.at('#a').attr<foo>, 0, 'right attribute';
is "$dom", '<div><div foo="0" id="a">A</div><div id="b">B</div></div>',
  'right result';

done-testing;
