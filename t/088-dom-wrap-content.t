#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Wrap content
my $dom = DOM::Tiny.parse('<a>Test</a>');
is $dom.at('a').wrap-content('A').tag, 'a', 'right tag';
is "$dom", '<a>Test</a>', 'right result';
is $dom.wrap-content('<b></b>').type, Root, 'right type';
is "$dom", '<b><a>Test</a></b>', 'right result';
is $dom.at('b').strip.at('a').tag('e:a').wrap-content('1<b c="d"></b>')
  .tag, 'e:a', 'right tag';
is "$dom", '<e:a>1<b c="d">Test</b></e:a>', 'right result';
is $dom.at('a').wrap-content('C<c><d>D</d><e>E</e></c>F').parent.type, Root, 'right type';
is "$dom", '<e:a>C<c><d>D1<b c="d">Test</b></d><e>E</e></c>F</e:a>',
  'right result';

done-testing;
