#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Broken "br" tag
my $dom = DOM::Tiny.parse('<br< abc abc abc abc abc abc abc abc<p>Test</p>');
is $dom.at('p').text, 'Test', 'right text';

done-testing;
