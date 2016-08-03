#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Replace element content
my $dom = DOM::Tiny.parse('<div>foo<p>lalala</p>bar</div>');
is $dom.at('p').content('bar'), '<p>bar</p>', 'right result';
is "$dom", '<div>foo<p>bar</p>bar</div>', 'right result';
$dom.at('p').content(DOM::Tiny.parse('text'));
is "$dom", '<div>foo<p>text</p>bar</div>', 'right result';
$dom = DOM::Tiny.parse('<div>foo</div><div>bar</div>');
$dom.find('div').map({ .content('<p>test</p>') });
is "$dom", '<div><p>test</p></div><div><p>test</p></div>', 'right result';
$dom.find('p').map({ .content('') });
is "$dom", '<div><p></p></div><div><p></p></div>', 'right result';
$dom = DOM::Tiny.parse('<div><p id="☃" /></div>');
$dom.at('#☃').content('♥');
is "$dom", '<div><p id="☃">♥</p></div>', 'right result';
$dom = DOM::Tiny.parse('<div>foo<p>lalala</p>bar</div>');
$dom.content('♥');
is "$dom", '♥', 'right result';
is $dom.content('<div>foo<p>lalala</p>bar</div>'),
  '<div>foo<p>lalala</p>bar</div>', 'right result';
is "$dom", '<div>foo<p>lalala</p>bar</div>', 'right result';
is $dom.content(''), '', 'no result';
is "$dom", '', 'no result';
$dom.content('<div>foo<p>lalala</p>bar</div>');
is "$dom", '<div>foo<p>lalala</p>bar</div>', 'right result';
is $dom.at('p').content(''), '<p></p>', 'right result';

done-testing;
