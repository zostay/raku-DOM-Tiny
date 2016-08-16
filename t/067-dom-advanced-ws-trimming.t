#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Advanced whitespace trimming (punctuation)
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head>
    <title>Real World!</title>
  <body>
    <div>foo <strong>bar</strong>.</div>
    <div>foo<strong>, bar</strong>baz<strong>; yada</strong>.</div>
    <div>foo<strong>: bar</strong>baz<strong>? yada</strong>!</div>
EOF
is $dom.find('html > head > title').[0].text, 'Real World!', 'right text';
is $dom.find('body > div').[0].all-text,      'foo bar.',    'right text';
is $dom.find('body > div').[1].all-text, 'foo, bar baz; yada.', 'right text';
is $dom.find('body > div').[1].text,     'foo baz.',            'right text';
is $dom.find('body > div').[2].all-text, 'foo: bar baz? yada!', 'right text';
is $dom.find('body > div').[2].text,     'foo baz!',            'right text';

done-testing;
