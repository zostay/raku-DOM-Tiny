#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# "image"
my $dom = DOM::Tiny.parse('<image src="foo.png">test');
is $dom.at('img')<src>, 'foo.png', 'right attribute';
is "$dom", '<img src="foo.png">test', 'right result';

done-testing;
