#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Huge number of attributes
my $dom = DOM::Tiny.parse('<div ' ~ ('a=b ' x 32768) ~ '>Test</div>');
is $dom.at('div[a=b]').text, 'Test', 'right text';

done-testing;
