#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# "title"
my $dom = DOM::Tiny.parse('<title> <p>test&lt;</title>');
is $dom.at('title').text, ' <p>test<', 'right text';
is "$dom", '<title> <p>test<</title>', 'right result';

done-testing;
