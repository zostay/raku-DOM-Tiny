#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Optional "head" and "body" tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head>
    <title>foo</title>
  <body>bar
EOF
say "$dom";
is $dom.at('html > head > title').text, 'foo', 'right text';
is $dom.at('html > body').text(:trim),         'bar', 'right text';

done-testing;
