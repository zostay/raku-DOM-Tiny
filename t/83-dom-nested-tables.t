#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Nested tables
my $dom = DOM::Tiny.parse(q:to/EOF/);
<table id="foo">
  <tr>
    <td>
      <table id="bar">
        <tr>
          <td>baz</td>
        </tr>
      </table>
    </td>
  </tr>
</table>
EOF
is $dom.find('#foo > tr > td > #bar > tr >td').[0].text, 'baz', 'right text';
is $dom.find('table > tr > td > table > tr >td').[0].text, 'baz',
  'right text';

# Nested find
$dom.parse(q:to/EOF/);
<c>
  <a>foo</a>
  <b>
    <a>bar</a>
    <c>
      <a>baz</a>
      <d>
        <a>yada</a>
      </d>
    </c>
  </b>
</c>
EOF
my @results = $dom.find('b').map({ .find('a').map({ .text }) }).flat;
is-deeply @results, <bar baz yada>.Array, 'right results';
@results = $dom.find('a').map({ .text });
is-deeply @results, <foo bar baz yada>.Array, 'right results';
@results = $dom.find('b').map({ .find('c a').map({ .text }) }).flat;
is-deeply @results, <baz yada>.Array, 'right results';
is $dom.at('b').at('a').text, 'bar', 'right text';
is $dom.at('c > b > a').text, 'bar', 'right text';
is $dom.at('b').at('c > b > a'), Nil, 'no result';

done-testing;
