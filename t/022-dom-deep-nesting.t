#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head>
    <title>Foo</title>
  </head>
  <body>
    <div id="container">
      <div id="header">
        <div id="logo">Hello World</div>
        <div id="buttons">
          <p id="foo">Foo</p>
        </div>
      </div>
      <form>
        <div id="buttons">
          <p id="bar">Bar</p>
        </div>
      </form>
      <div id="content">More stuff</div>
    </div>
  </body>
</html>
EOF
my $p = $dom.find('body > #container > div p[id]').cache;
is $p[0].attr('id'), 'foo', 'right id attribute';
is $p[1], Nil, 'no second result';
is $p.elems, 1, 'right number of elements';
my @p;
my @div;
$dom.find('div').map({ push @div, .attr('id') });
$dom.find('p').map({ push @p, .attr('id') });
is-deeply @p, <foo bar>.Array, 'found all p elements';
my @ids = <container header logo buttons buttons content>;
is-deeply @div, @ids, 'found all div elements';
is-deeply $dom.at('p').ancestors».tag,
    <div div div body html>, 'right results';
is-deeply $dom.at('html').ancestors.Array, [], 'no results';
is-deeply $dom.ancestors.Array,             [], 'no results';

done-testing;
