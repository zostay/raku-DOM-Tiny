#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.parse(
  '<!DOCTYPE before><p>test<![CDATA[123]]><!-- 456 --></p><?after?>');
is $dom.at('p').preceding-nodes.first.content, 'before', 'right content';
is $dom.at('p').preceding-nodes.elems, 1, 'right number of nodes';
is $dom.at('p').child-nodes[*-1].preceding-nodes.first.content, 'test',
  'right content';
is $dom.at('p').child-nodes[*-1].preceding-nodes[*-1].content, '123',
  'right content';
is $dom.at('p').child-nodes[*-1].preceding-nodes.elems, 2,
  'right number of nodes';
is $dom.preceding-nodes.elems, 0, 'no preceding nodes';
is $dom.at('p').following-nodes.first.content, 'after', 'right content';
is $dom.at('p').following-nodes.elems, 1, 'right number of nodes';
is $dom.child-nodes.first.following-nodes.first.tag, 'p', 'right tag';
is $dom.child-nodes.first.following-nodes[*-1].content, 'after',
  'right content';
is $dom.child-nodes.first.following-nodes.elems, 2, 'right number of nodes';
is $dom.following-nodes.elems, 0, 'no following nodes';
is $dom.at('p').previous-node.content,       'before', 'right content';
is $dom.at('p').previous-node.previous-node, Nil,     'no more siblings';
is $dom.at('p').next-node.content,           'after',   'right content';
is $dom.at('p').next-node.next-node,         Nil,     'no more siblings';
is $dom.at('p').child-nodes[*-1].previous-node.previous-node.content,
  'test', 'right content';
is $dom.at('p').child-nodes.first.next-node.next-node.content, ' 456 ',
  'right content';
is $dom.descendant-nodes[0].type,    Doctype, 'right type';
is $dom.descendant-nodes[0].content, 'before', 'right content';
is $dom.descendant-nodes[0], '<!DOCTYPE before>', 'right content';
is $dom.descendant-nodes[1].tag,     'p',     'right tag';
is $dom.descendant-nodes[2].type,    Text,  'right type';
is $dom.descendant-nodes[2].content, 'test',  'right content';
is $dom.descendant-nodes[5].type,    PI,    'right type';
is $dom.descendant-nodes[5].content, 'after', 'right content';
is $dom.at('p').descendant-nodes[0].type,    Text, 'right type';
is $dom.at('p').descendant-nodes[0].content, 'test', 'right type';
is $dom.at('p').descendant-nodes[*-1].type,    Comment, 'right type';
is $dom.at('p').descendant-nodes[*-1].content, ' 456 ',   'right type';
is $dom.child-nodes[1].child-nodes.first.parent.tag, 'p', 'right tag';
is $dom.child-nodes[1].child-nodes.first.content, 'test', 'right content';
is $dom.child-nodes[1].child-nodes.first, 'test', 'right content';
is $dom.at('p').child-nodes.first.type, Text, 'right type';
is $dom.at('p').child-nodes.first.remove.tag, 'p', 'right tag';
is $dom.at('p').child-nodes.first.type,    CDATA, 'right type';
is $dom.at('p').child-nodes.first.content, '123',   'right content';
is $dom.at('p').child-nodes[1].type,    Comment, 'right type';
is $dom.at('p').child-nodes[1].content, ' 456 ',   'right content';
is $dom[0].type,    Doctype, 'right type';
is $dom[0].content, 'before', 'right content';
is $dom.child-nodes[2].type,    PI,    'right type';
is $dom.child-nodes[2].content, 'after', 'right content';
is $dom.child-nodes.first.content('again').content, 'again',
  'right content';
is $dom.child-nodes.grep({ .type ~~ PI })».remove.first.type, Root, 'right type';
is "$dom", '<!DOCTYPE again><p><![CDATA[123]]><!-- 456 --></p>', 'right result';

done-testing;
