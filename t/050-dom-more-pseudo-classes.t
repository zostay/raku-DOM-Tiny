#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# More pseudo-classes
my $dom = DOM::Tiny.parse(q:to/EOF/);
<ul>
    <li>A</li>
    <li>B</li>
    <li>C</li>
    <li>D</li>
    <li>E</li>
    <li>F</li>
    <li>G</li>
    <li>H</li>
</ul>
EOF
my @li = $dom.find('li:nth-child(odd)').map({ .text });
is-deeply @li, <A C E G>.Array, 'found all odd li elements';
@li = $dom.find('li:NTH-CHILD(ODD)').map({ .text });
is-deeply @li, <A C E G>.Array, 'found all odd li elements';
@li = $dom.find('li:nth-last-child(odd)').map({ .text });
is-deeply @li, <B D F H>.Array, 'found all odd li elements';
is $dom.find(':nth-child(odd)').[0].tag,      'ul', 'right tag';
is $dom.find(':nth-child(odd)').[1].text,     'A',  'right text';
is $dom.find(':nth-child(1)').[0].tag,        'ul', 'right tag';
is $dom.find(':nth-child(1)').[1].text,       'A',  'right text';
is $dom.find(':nth-last-child(odd)').[0].tag, 'ul', 'right tag';
is $dom.find(':nth-last-child(odd)').[*-1].text, 'H', 'right text';
is $dom.find(':nth-last-child(1)').[0].tag,  'ul', 'right tag';
is $dom.find(':nth-last-child(1)').[1].text, 'H',  'right text';
@li = $dom.find('li:nth-child(2n+1)').map({ .text });
is-deeply @li, <A C E G>.Array, 'found all odd li elements';
@li = $dom.find('li:nth-child(2n + 1)').map({ .text });
is-deeply @li, <A C E G>.Array, 'found all odd li elements';
@li = $dom.find('li:nth-last-child(2n+1)').map({ .text });
is-deeply @li, <B D F H>.Array, 'found all odd li elements';
@li = $dom.find('li:nth-child(even)').map({ .text });
is-deeply @li, <B D F H>.Array, 'found all even li elements';
@li = $dom.find('li:NTH-CHILD(EVEN)').map({ .text });
is-deeply @li, <B D F H>.Array, 'found all even li elements';
@li = $dom.find('li:nth-last-child( even )').map({ .text });
is-deeply @li, <A C E G>.Array, 'found all even li elements';
@li = $dom.find('li:nth-child(2n+2)').map({ .text });
is-deeply @li, <B D F H>.Array, 'found all even li elements';
@li = $dom.find('li:nTh-chILd(2N+2)').map({ .text });
is-deeply @li, <B D F H>.Array, 'found all even li elements';
@li = $dom.find('li:nth-child( 2n + 2 )').map({ .text });
is-deeply @li, <B D F H>.Array, 'found all even li elements';
@li = $dom.find('li:nth-last-child(2n+2)').map({ .text });
is-deeply @li, <A C E G>.Array, 'found all even li elements';
@li = $dom.find('li:nth-child(4n+1)').map({ .text });
is-deeply @li, <A E>.Array, 'found the right li elements';
@li = $dom.find('li:nth-last-child(4n+1)').map({ .text });
is-deeply @li, <D H>.Array, 'found the right li elements';
@li = $dom.find('li:nth-child(4n+4)').map({ .text });
is-deeply @li, <D H>.Array, 'found the right li elements';
@li = $dom.find('li:nth-last-child(4n+4)').map({ .text });
is-deeply @li, <A E>.Array, 'found the right li elements';
@li = $dom.find('li:nth-child(4n)').map({ .text });
is-deeply @li, <D H>.Array, 'found the right li elements';
@li = $dom.find('li:nth-child( 4n )').map({ .text });
is-deeply @li, <D H>.Array, 'found the right li elements';
@li = $dom.find('li:nth-last-child(4n)').map({ .text });
is-deeply @li, <A E>.Array, 'found the right li elements';
@li = $dom.find('li:nth-child(5n-2)').map({ .text });
is-deeply @li, <C H>.Array, 'found the right li elements';
@li = $dom.find('li:nth-child( 5n - 2 )').map({ .text });
is-deeply @li, <C H>.Array, 'found the right li elements';
@li = $dom.find('li:nth-last-child(5n-2)').map({ .text });
is-deeply @li, <A F>.Array, 'found the right li elements';
@li = $dom.find('li:nth-child(-n+3)').map({ .text });
is-deeply @li, <A B C>.Array, 'found first three li elements';
@li = $dom.find('li:nth-child( -n + 3 )').map({ .text });
is-deeply @li, <A B C>.Array, 'found first three li elements';
@li = $dom.find('li:nth-last-child(-n+3)').map({ .text });
is-deeply @li, <F G H>.Array, 'found last three li elements';
@li = $dom.find('li:nth-child(-1n+3)').map({ .text });
is-deeply @li, <A B C>.Array, 'found first three li elements';
@li = $dom.find('li:nth-last-child(-1n+3)').map({ .text });
is-deeply @li, <F G H>.Array, 'found first three li elements';
@li = $dom.find('li:nth-child(3n)').map({ .text });
is-deeply @li, <C F>.Array, 'found every third li elements';
@li = $dom.find('li:nth-last-child(3n)').map({ .text });
is-deeply @li, <C F>.Array, 'found every third li elements';
@li = $dom.find('li:NTH-LAST-CHILD(3N)').map({ .text });
is-deeply @li, <C F>.Array, 'found every third li elements';
@li = $dom.find('li:Nth-Last-Child(3N)').map({ .text });
is-deeply @li, <C F>.Array, 'found every third li elements';
@li = $dom.find('li:nth-child( 3 )').map({ .text });
is-deeply @li, ['C'], 'found third li element';
@li = $dom.find('li:nth-last-child( +3 )').map({ .text });
is-deeply @li, ['F'], 'found third last li element';
@li = $dom.find('li:nth-child(1n+0)').map({ .text });
is-deeply @li, <A B C D E F G H>.Array, 'found all li elements';
@li = $dom.find('li:nth-child(1n-0)').map({ .text });
is-deeply @li, <A B C D E F G H>.Array, 'found all li elements';
@li = $dom.find('li:nth-child(n+0)').map({ .text });
is-deeply @li, <A B C D E F G H>.Array, 'found all li elements';
@li = $dom.find('li:nth-child(n)').map({ .text });
is-deeply @li, <A B C D E F G H>.Array, 'found all li elements';
@li = $dom.find('li:nth-child(n+0)').map({ .text });
is-deeply @li, <A B C D E F G H>.Array, 'found all li elements';
@li = $dom.find('li:NTH-CHILD(N+0)').map({ .text });
is-deeply @li, <A B C D E F G H>.Array, 'found all li elements';
@li = $dom.find('li:Nth-Child(N+0)').map({ .text });
is-deeply @li, <A B C D E F G H>.Array, 'found all li elements';
@li = $dom.find('li:nth-child(n)').map({ .text });
is-deeply @li, <A B C D E F G H>.Array, 'found all li elements';
@li = $dom.find('li:nth-child(0n+1)').map({ .text });
is-deeply @li, <A>.Array, 'found first li element';
is $dom.find('li:nth-child(0n+0)').elems,     0, 'no results';
is $dom.find('li:nth-child(0)').elems,        0, 'no results';
is $dom.find('li:nth-child()').elems,         0, 'no results';
is $dom.find('li:nth-child(whatever)').elems, 0, 'no results';
is $dom.find('li:whatever(whatever)').elems,  0, 'no results';

done-testing;
