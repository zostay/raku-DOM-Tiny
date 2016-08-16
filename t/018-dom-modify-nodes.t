#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.parse('<script>la<la>la</script>');
is $dom.at('script').type, Tag, 'right type';
is $dom.at('script')[0].type,    Raw,      'right type';
is $dom.at('script')[0].content, 'la<la>la', 'right content';
is "$dom", '<script>la<la>la</script>', 'right result';
is $dom.at('script').child-nodes.first.replace('a<b>c</b>1<b>d</b>').tag,
  'script', 'right tag';
is "$dom", '<script>a<b>c</b>1<b>d</b></script>', 'right result';
is $dom.at('b').child-nodes.first.append('e').content, 'c',
  'right content';
is $dom.at('b').child-nodes.first.prepend('f').type, Text, 'right type';
is "$dom", '<script>a<b>fce</b>1<b>d</b></script>', 'right result';
is $dom.at('script').child-nodes.first.following.first.tag, 'b',
  'right tag';
is $dom.at('script').child-nodes.first.next.content, 'fce',
  'right content';
is $dom.at('script').child-nodes.first.previous, Nil, 'no siblings';
is $dom.at('script').child-nodes[2].previous.content, 'fce',
  'right content';
is $dom.at('b').child-nodes[1].next, Nil, 'no siblings';
is $dom.at('script').child-nodes.first.wrap('<i>:)</i>').root,
  '<script><i>:)a</i><b>fce</b>1<b>d</b></script>', 'right result';
is $dom.at('i').child-nodes.first.wrap-content('<b></b>').root,
  '<script><i>:)a</i><b>fce</b>1<b>d</b></script>', 'no changes';
is $dom.at('i').child-nodes.first.wrap('<b></b>').root,
  '<script><i><b>:)</b>a</i><b>fce</b>1<b>d</b></script>', 'right result';
  is $dom.at('b').child-nodes.first.ancestors».tag.join(','),
  'b,i,script', 'right result';
is $dom.at('b').child-nodes.first.append-content('g').content, ':)g',
  'right content';
is $dom.at('b').child-nodes.first.prepend-content('h').content, 'h:)g',
  'right content';
is "$dom", '<script><i><b>h:)g</b>a</i><b>fce</b>1<b>d</b></script>',
  'right result';
is $dom.at('script > b:last-of-type').append('<!--y-->')
  .following-nodes.first.content, 'y', 'right content';
is $dom.at('i').prepend('z').preceding-nodes.first.content, 'z',
  'right content';
is $dom.at('i').following[*-1].text, 'd', 'right text';
is $dom.at('i').following.elems, 2, 'right number of following elements';
is $dom.at('i').following('b:last-of-type').first.text, 'd', 'right text';
is $dom.at('i').following('b:last-of-type').elems, 1,
  'right number of following elements';
is $dom.following.elems, 0, 'no following elements';
is $dom.at('script > b:last-of-type').preceding.first.tag, 'i', 'right tag';
is $dom.at('script > b:last-of-type').preceding.elems, 2,
  'right number of preceding elements';
is $dom.at('script > b:last-of-type').preceding('b').first.tag, 'b',
  'right tag';
is $dom.at('script > b:last-of-type').preceding('b').elems, 1,
  'right number of preceding elements';
is $dom.preceding.elems, 0, 'no preceding elements';
is "$dom", '<script>z<i><b>h:)g</b>a</i><b>fce</b>1<b>d</b><!--y--></script>',
  'right result';

done-testing;
