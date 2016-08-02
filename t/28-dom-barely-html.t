#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Looks remotely like HTML
my $dom = DOM::Tiny.parse(
  '<!DOCTYPE H "-/W/D HT 4/E">☃<title class=test>♥</title>☃');
is $dom.at('title').text, '♥', 'right text';
is $dom.at('*').text,     '♥', 'right text';
is $dom.at('.test').text, '♥', 'right text';

done-testing;
