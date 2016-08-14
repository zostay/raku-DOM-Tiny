#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Even more pseudo-classes
my $dom = DOM::Tiny.parse(q:to/EOF/);
<ul>
    <li>A</li>
    <p>B</p>
    <li class="test ♥">C</li>
    <p>D</p>
    <li>E</li>
    <li>F</li>
    <p>G</p>
    <li>H</li>
    <li>I</li>
</ul>
<div>
    <div class="☃">J</div>
</div>
<div>
    <a href="http://www.w3.org/DOM/">DOM</a>
    <div class="☃">K</div>
    <a href="http://www.w3.org/DOM/">DOM</a>
</div>
EOF
my @e = $dom.find('ul :nth-child(odd)').map({ .text });
is-deeply @e, <A C E G I>.Array, 'found all odd elements';
@e = $dom.find('li:nth-of-type(odd)').map({ .text });
is-deeply @e, <A E H>.Array, 'found all odd li elements';
@e = $dom.find('li:nth-last-of-type( odd )').map({ .text });
is-deeply @e, <C F I>.Array, 'found all odd li elements';
@e = $dom.find('p:nth-of-type(odd)').map({ .text });
is-deeply @e, <B G>.Array, 'found all odd p elements';
@e = $dom.find('p:nth-last-of-type(odd)').map({ .text });
is-deeply @e, <B G>.Array, 'found all odd li elements';
@e = $dom.find('ul :nth-child(1)').map({ .text });
is-deeply @e, ['A'], 'found first child';
@e = $dom.find('ul :first-child').map({ .text });
is-deeply @e, ['A'], 'found first child';
@e = $dom.find('p:nth-of-type(1)').map({ .text });
is-deeply @e, ['B'], 'found first child';
@e = $dom.find('p:first-of-type').map({ .text });
is-deeply @e, ['B'], 'found first child';
@e = $dom.find('li:nth-of-type(1)').map({ .text });
is-deeply @e, ['A'], 'found first child';
@e = $dom.find('li:first-of-type').map({ .text });
is-deeply @e, ['A'], 'found first child';
@e = $dom.find('ul :nth-last-child(-n+1)').map({ .text });
is-deeply @e, ['I'], 'found last child';
@e = $dom.find('ul :last-child').map({ .text });
is-deeply @e, ['I'], 'found last child';
@e = $dom.find('p:nth-last-of-type(-n+1)').map({ .text });
is-deeply @e, ['G'], 'found last child';
@e = $dom.find('p:last-of-type').map({ .text });
is-deeply @e, ['G'], 'found last child';
@e = $dom.find('li:nth-last-of-type(-n+1)').map({ .text });
is-deeply @e, ['I'], 'found last child';
@e = $dom.find('li:last-of-type').map({ .text });
is-deeply @e, ['I'], 'found last child';
@e = $dom.find('ul :nth-child(-n+3):not(li)').map({ .text });
is-deeply @e, ['B'], 'found first p element';
@e = $dom.find('ul :nth-child(-n+3):NOT(li)').map({ .text });
is-deeply @e, ['B'], 'found first p element';
@e = $dom.find('ul :nth-child(-n+3):not(:first-child)')
  .map({ .text });
is-deeply @e, <B C>.Array, 'found second and third element';
@e = $dom.find('ul :nth-child(-n+3):not(.♥)').map({ .text });
is-deeply @e, <A B>.Array, 'found first and second element';
@e = $dom.find('ul :nth-child(-n+3):not([class$="♥"])')
  .map({ .text });
is-deeply @e, <A B>.Array, 'found first and second element';
@e = $dom.find('ul :nth-child(-n+3):not(li[class$="♥"])')
  .map({ .text });
is-deeply @e, <A B>.Array, 'found first and second element';
@e = $dom.find('ul :nth-child(-n+3):not([class$="♥"][class^="test"])')
  .map({ .text });
is-deeply @e, <A B>.Array, 'found first and second element';
@e = $dom.find('ul :nth-child(-n+3):not(*[class$="♥"])')
  .map({ .text });
is-deeply @e, <A B>.Array, 'found first and second element';
@e = $dom.find('ul :nth-child(-n+3):not(:nth-child(-n+2))')
  .map({ .text });
is-deeply @e, ['C'], 'found third element';
@e = $dom.find('ul :nth-child(-n+3):not(:nth-child(1)):not(:nth-child(2))')
  .map({ .text });
is-deeply @e, ['C'], 'found third element';
@e = $dom.find(':only-child').map({ .text });
is-deeply @e, ['J'], 'found only child';
@e = $dom.find('div :only-of-type').map({ .text });
is-deeply @e, <J K>.Array, 'found only child';
@e = $dom.find('div:only-child').map({ .text });
is-deeply @e, ['J'], 'found only child';
@e = $dom.find('div div:only-of-type').map({ .text });
is-deeply @e, <J K>.Array, 'found only child';

done-testing;
