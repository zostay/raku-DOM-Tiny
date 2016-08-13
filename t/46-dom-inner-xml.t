#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Inner XML
my $dom = DOM::Tiny.parse('<a>xxx<x>x</x>xxx</a>');
is $dom.at('a').content, 'xxx<x>x</x>xxx', 'right result';
is $dom.content, '<a>xxx<x>x</x>xxx</a>', 'right result';

done-testing;
