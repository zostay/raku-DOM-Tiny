#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Real world JavaScript and CSS
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head>
    <style test=works>#style { foo: style('<test>'); }</style>
    <script>
      if (a < b) {
        alert('<123>');
      }
    </script>
    < sCriPt two="23" >if (b > c) { alert('&<ohoh>') }< / scRiPt >
  <body>Foo!</body>
EOF
is $dom.find('html > body').[0].text, 'Foo!', 'right text';
is $dom.find('html > head > style').[0].text,
  "#style \{ foo: style('<test>'); }", 'right text';
is $dom.find('html > head > script').[0].text,
  "\n      if (a < b) \{\n        alert('<123>');\n      }\n    ", 'right text';
is $dom.find('html > head > script').[1].text,
  "if (b > c) \{ alert('&<ohoh>') }", 'right text';

done-testing;
