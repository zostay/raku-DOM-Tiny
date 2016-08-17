#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Direct hash access to attributes in XML mode
my $dom = DOM::Tiny.new(:xml).parse(q:to/EOF/);
<a id="one">
  <B class="two" test>
    foo
    <c id="three">bar</c>
    <c ID="four">baz</c>
  </B>
</a>
EOF
ok $dom.xml, 'XML mode active';
is $dom.at('a')<id>, 'one', 'right attribute';
is-deeply [$dom.at('a').attr.keys.sort], ['id'], 'right attributes';
is $dom.at('a').at('B').text(:trim), 'foo', 'right text';
is $dom.at('B')<class>, 'two', 'right attribute';
is-deeply [$dom.at('a B').attr.keys.sort], <class test>.Array, 'right attributes';
is $dom.find('a B c').[0].text, 'bar', 'right text';
is $dom.find('a B c').[0]<id>, 'three', 'right attribute';
is-deeply [$dom.find('a B c').[0].attr.keys.sort], ['id'], 'right attributes';
is $dom.find('a B c').[1].text, 'baz', 'right text';
is $dom.find('a B c').[1]<ID>, 'four', 'right attribute';
is-deeply [$dom.find('a B c').[1].attr.keys.sort], ['ID'], 'right attributes';
is $dom.find('a B c').[2], Nil, 'no result';
is $dom.find('a B c').elems, 2, 'right number of elements';
my @results = $dom.find('a B c').map({ .text });
is-deeply @results, <bar baz>.Array, 'right results';
is $dom.find('a B c').join("\n"),
  qq{<c id="three">bar</c>\n<c ID="four">baz</c>}, 'right result';
is-deeply [keys $dom.attr], [], 'root has no attributes';
is $dom.find('#nothing').join, '', 'no result';

done-testing;
