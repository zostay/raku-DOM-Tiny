#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Broken "div" blocks
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head><title>Test</title></head>
  <body>
    <div>
    <table>
      <tr><td><div>test</td></div></tr>
      </div>
    </table>
  </body>
</html>
EOF
is $dom.at('html head title').text,                 'Test', 'right text';
is $dom.at('html body div table tr td > div').text, 'test', 'right text';

done-testing;
