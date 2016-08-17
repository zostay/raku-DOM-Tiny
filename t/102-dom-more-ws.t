#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Selectors with leading and trailing whitespace
my $dom = DOM::Tiny.parse('<div id=foo><b>works</b></div>');
is $dom.at(' div   b ').text,          'works', 'right text';
is $dom.at('  :not(  #foo  )  ').text, 'works', 'right text';

done-testing;
