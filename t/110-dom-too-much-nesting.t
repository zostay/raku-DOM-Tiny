#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

plan 2;

# Huge number of nested tags
my $huge = ('<a>' x 100) ~ 'works' ~ ('</a>' x 100);
my $dom = DOM::Tiny.parse($huge);
is $dom.all-text, 'works', 'right text';
is "$dom", $huge, 'right result';
