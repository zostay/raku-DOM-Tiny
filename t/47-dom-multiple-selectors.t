#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Multiple selectors
my $dom = DOM::Tiny.parse(
  '<div id="a">A</div><div id="b">B</div><div id="c">C</div><p>D</p>');
my @div = $dom.find('p, div').map({ .text });
is-deeply @div, <A B C D>.Array, 'found all elements';
@div = $dom.find('#a, #c').map({ .text });
is-deeply @div, <A C>.Array, 'found all div elements with the right ids';
@div = $dom.find('div#a, div#b').map({ .text });
is-deeply @div, <A B>.Array, 'found all div elements with the right ids';
@div = $dom.find('div[id="a"], div[id="c"]').map({ .text });
is-deeply @div, <A C>.Array, 'found all div elements with the right ids';
$dom = DOM::Tiny.parse(
  '<div id="☃">A</div><div id="b">B</div><div id="♥x">C</div>');
@div = $dom.find('#☃, #♥x').map({ .text });
is-deeply @div, <A C>.Array, 'found all div elements with the right ids';
@div = $dom.find('div#☃, div#b').map({ .text });
is-deeply @div, <A B>.Array, 'found all div elements with the right ids';
@div = $dom.find('div[id="☃"], div[id="♥x"]')\
  .map({ .text });
is-deeply @div, <A C>.Array, 'found all div elements with the right ids';

done-testing;
