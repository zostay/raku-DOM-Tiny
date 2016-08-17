#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Real world table
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head>
    <title>Real World!</title>
  <body>
    <p>Just a test
    <table class=RealWorld>
      <thead>
        <tr>
          <th class=one>One
          <th class=two>Two
          <th class=three>Three
          <th class=four>Four
      <tbody>
        <tr>
          <td class=alpha>Alpha
          <td class=beta>Beta
          <td class=gamma><a href="#gamma">Gamma</a>
          <td class=delta>Delta
        <tr>
          <td class=alpha>Alpha Two
          <td class=beta>Beta Two
          <td class=gamma><a href="#gamma-two">Gamma Two</a>
          <td class=delta>Delta Two
    </table>
EOF
is $dom.find('html > head > title').[0].text, 'Real World!', 'right text';
is $dom.find('html > body > p').[0].text(:trim),     'Just a test', 'right text';
is $dom.find('p').[0].text(:trim),                   'Just a test', 'right text';
is $dom.find('thead > tr > .three').[0].text(:trim), 'Three',       'right text';
is $dom.find('thead > tr > .four').[0].text(:trim),  'Four',        'right text';
is $dom.find('tbody > tr > .beta').[0].text(:trim),  'Beta',        'right text';
is $dom.find('tbody > tr > .gamma').[0].text(:trim), '',            'no text';
is $dom.find('tbody > tr > .gamma > a').[0].text, 'Gamma',     'right text';
is $dom.find('tbody > tr > .alpha').[1].text(:trim),     'Alpha Two', 'right text';
is $dom.find('tbody > tr > .gamma > a').[1].text, 'Gamma Two', 'right text';
my @following
  = $dom.find('tr > td:nth-child(1)').map({ .following(':nth-child(even)') })
  .flat.map({ .all-text(:trim) });
is-deeply @following, ['Beta', 'Delta', 'Beta Two', 'Delta Two'],
  'right results';

done-testing;
