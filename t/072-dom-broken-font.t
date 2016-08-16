#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Broken "font" block and useless end tags
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head><title>Test</title></head>
  <body>
    <table>
      <tr><td><font>test</td></font></tr>
      </tr>
    </table>
  </body>
</html>
EOF
is $dom.at('html > head > title').text,          'Test', 'right text';
is $dom.at('html body table tr td > font').text, 'test', 'right text';

done-testing;
