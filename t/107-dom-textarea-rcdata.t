#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# "textarea"
my $dom = DOM::Tiny.parse('<textarea id="a"> <p>test&lt;</textarea>');
is $dom.at('textarea#a').text, ' <p>test<', 'right text';
is "$dom", '<textarea id="a"> <p>test<</textarea>', 'right result';

done-testing;
