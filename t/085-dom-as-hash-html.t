#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Direct hash access to attributes in HTML mode
my $dom = DOM::Tiny.parse(q:to/EOF/);
<a id="one">
  <B class="two" test>
    foo
    <c id="three">bar</c>
    <c ID="four">baz</c>
  </B>
</a>
EOF
ok !$dom.xml, 'XML mode not active';
is $dom.at('a')<id>, 'one', 'right attribute';
is-deeply [$dom.at('a').attr.keys.sort], ['id'], 'right attributes';
is $dom.at('a').at('b').text(:trim), 'foo', 'right text';
is $dom.at('b')<class>, 'two', 'right attribute';
is-deeply [$dom.at('a b').attr.keys.sort], <class test>.Array, 'right attributes';
is $dom.find('a b c').[0].text, 'bar', 'right text';
is $dom.find('a b c').[0]<id>, 'three', 'right attribute';
is-deeply [$dom.find('a b c').[0].attr.keys.sort], ['id'], 'right attributes';
is $dom.find('a b c').[1].text, 'baz', 'right text';
is $dom.find('a b c').[1]<id>, 'four', 'right attribute';
is-deeply [$dom.find('a b c').[1].attr.keys.sort], ['id'], 'right attributes';
is $dom.find('a b c').[2], Nil, 'no result';
is $dom.find('a b c').elems, 2, 'right number of elements';
my @results = $dom.find('a b c').map({ .text });
is-deeply @results, <bar baz>.Array, 'right results';
is $dom.find('a b c').join("\n"),
  qq{<c id="three">bar</c>\n<c id="four">baz</c>}, 'right result';
is-deeply [keys $dom.attr], [], 'root has no attributes';
is $dom.find('#nothing').join, '', 'no result';

done-testing;
