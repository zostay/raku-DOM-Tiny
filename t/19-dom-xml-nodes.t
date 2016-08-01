#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.new(:xml).parse('<b>test<image /></b>');
ok $dom.at('b').child-nodes.first.xml, 'XML mode active';
ok $dom.at('b').child-nodes.first.replace('<br>').child-nodes.first.xml,
  'XML mode active';
is "$dom", '<b><br /><image /></b>', 'right result';

done-testing;
