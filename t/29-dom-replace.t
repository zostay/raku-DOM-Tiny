#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Replace elements
my $dom = DOM::Tiny.parse('<div>foo<p>lalala</p>bar</div>');
is $dom.at('p').replace('<foo>bar</foo>'), '<div>foo<foo>bar</foo>bar</div>',
  'right result';
is "$dom", '<div>foo<foo>bar</foo>bar</div>', 'right result';
$dom.at('foo').replace(DOM::Tiny.parse('text'));
is "$dom", '<div>footextbar</div>', 'right result';
$dom = DOM::Tiny.parse('<div>foo</div><div>bar</div>');
$dom.find('div').map({ .replace('<p>test</p>') });
is "$dom", '<p>test</p><p>test</p>', 'right result';
$dom = DOM::Tiny.parse('<div>foo<p>lalala</p>bar</div>');
is $dom.replace('♥'), '♥', 'right result';
is "$dom", '♥', 'right result';
$dom.replace('<div>foo<p>lalala</p>bar</div>');
is "$dom", '<div>foo<p>lalala</p>bar</div>', 'right result';
is $dom.at('p').replace(''), '<div>foobar</div>', 'right result';
is "$dom", '<div>foobar</div>', 'right result';
is $dom.replace(''), '', 'no result';
is "$dom", '', 'no result';
$dom.replace('<div>foo<p>lalala</p>bar</div>');
is "$dom", '<div>foo<p>lalala</p>bar</div>', 'right result';
$dom.find('p')».replace('');
is "$dom", '<div>foobar</div>', 'right result';
$dom = DOM::Tiny.parse('<div>♥</div>');
$dom.at('div').content('☃');
is "$dom", '<div>☃</div>', 'right result';
$dom = DOM::Tiny.parse('<div>♥</div>');
$dom.at('div').content("\x[2603]");
is $dom.Str, '<div>☃</div>', 'right result';
is $dom.at('div').replace('<p>♥</p>').root, '<p>♥</p>', 'right result';
is $dom.Str, '<p>♥</p>', 'right result';
is $dom.replace('<b>whatever</b>').root, '<b>whatever</b>', 'right result';
is $dom.Str, '<b>whatever</b>', 'right result';
$dom.at('b').prepend('<p>foo</p>').append('<p>bar</p>');
is "$dom", '<p>foo</p><b>whatever</b><p>bar</p>', 'right result';
is $dom.find('p')».remove.first.root.at('b').text, 'whatever',
  'right result';
is "$dom", '<b>whatever</b>', 'right result';
is $dom.at('b').strip, 'whatever', 'right result';
is $dom.strip,  'whatever', 'right result';
is $dom.remove, '',         'right result';
$dom.replace('A<div>B<p>C<b>D<i><u>E</u></i>F</b>G</p><div>H</div></div>I');
is $dom.find(':not(div):not(i):not(u)')».strip.first.root,
  'A<div>BCD<i><u>E</u></i>FG<div>H</div></div>I', 'right result';
is $dom.at('i').Str, '<i><u>E</u></i>', 'right result';
$dom = DOM::Tiny.parse('<div><div>A</div><div>B</div>C</div>');
is $dom.at('div').at('div').text, 'A', 'right text';
$dom.at('div').find('div')».strip;
is "$dom", '<div>ABC</div>', 'right result';

done-testing;
