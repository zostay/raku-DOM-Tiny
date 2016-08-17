#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Real world list
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head>
    <title>Real World!</title>
  <body>
    <ul>
      <li>
        Test
        <br>
        123
        <p>

      <li>
        Test
        <br>
        321
        <p>
      <li>
        Test
        3
        2
        1
        <p>
    </ul>
EOF
is $dom.find('html > head > title').[0].text,    'Real World!', 'right text';
is $dom.find('body > ul > li').[0].text(:trim),         'Test 123',    'right text';
is $dom.find('body > ul > li > p').[0].text(:trim),     '',            'no text';
is $dom.find('body > ul > li').[1].text(:trim),         'Test 321',    'right text';
is $dom.find('body > ul > li > p').[1].text(:trim),     '',            'no text';
is $dom.find('body > ul > li').[1].all-text(:trim),     'Test 321',    'right text';
is $dom.find('body > ul > li > p').[1].all-text(:trim), '',            'no text';
is $dom.find('body > ul > li').[2].text(:trim),         'Test 3 2 1',  'right text';
is $dom.find('body > ul > li > p').[2].text(:trim),     '',            'no text';
is $dom.find('body > ul > li').[2].all-text(:trim),     'Test 3 2 1',  'right text';
is $dom.find('body > ul > li > p').[2].all-text(:trim), '',            'no text';

done-testing;
