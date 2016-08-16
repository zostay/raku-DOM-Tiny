#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.parse('foo<b>bar</b>baz');
is $dom.child-nodes.first.child-nodes.elems,      0, 'no nodes';
is $dom.child-nodes.first.descendant-nodes.elems, 0, 'no nodes';
is $dom.child-nodes.first.children.elems,         0, 'no children';
is $dom.child-nodes.first.strip.parent, 'foo<b>bar</b>baz', 'no changes';
is $dom.child-nodes.first.at('b'), Nil, 'no result';
is $dom.child-nodes.first.find('*').elems, 0, 'no results';
ok !$dom.child-nodes.first.matches('*'), 'no match';
is-deeply $dom.child-nodes.first.attr, {}, 'no attributes';
is $dom.child-nodes.first.namespace, Nil, 'no namespace';
is $dom.child-nodes.first.tag,       Nil, 'no tag';
is $dom.child-nodes.first.text,      'foo',    'right text';
is $dom.child-nodes.first.all-text,  'foo',    'right text';

done-testing;
