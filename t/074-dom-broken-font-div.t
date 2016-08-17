#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Broken "font" and "div" blocks
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head><title>Test</title></head>
  <body>
    <font>
    <div>test1<br>
      <div>test2<br></font>
    </div>
  </body>
</html>
EOF
is $dom.at('html head title').text,            'Test',  'right text';
is $dom.at('html body font > div').text(:trim),       'test1', 'right text';
is $dom.at('html body font > div > div').text(:trim), 'test2', 'right text';

done-testing;
