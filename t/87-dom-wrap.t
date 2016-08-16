#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Wrap elements
my $dom = DOM::Tiny.parse('<a>Test</a>');
is "$dom", '<a>Test</a>', 'right result';
is $dom.wrap('<b></b>').type, Root, 'right type';
is "$dom", '<a>Test</a>', 'no changes';
is $dom.at('a').wrap('<b></b>').type, Tag, 'right type';
is "$dom", '<b><a>Test</a></b>', 'right result';
is $dom.at('b').strip.at('a').wrap('A').tag, 'a', 'right tag';
is "$dom", '<a>Test</a>', 'right result';
is $dom.at('a').wrap('<b></b>').tag, 'a', 'right tag';
is "$dom", '<b><a>Test</a></b>', 'right result';
is $dom.at('a').wrap('C<c><d>D</d><e>E</e></c>F').parent.tag, 'd',
  'right tag';
is "$dom", '<b>C<c><d>D<a>Test</a></d><e>E</e></c>F</b>', 'right result';

done-testing;
