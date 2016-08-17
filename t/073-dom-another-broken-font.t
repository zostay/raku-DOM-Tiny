#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Different broken "font" block
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head><title>Test</title></head>
  <body>
    <font>
    <table>
      <tr>
        <td>test1<br></td></font>
        <td>test2<br>
    </table>
  </body>
</html>
EOF
is $dom.at('html > head > title').text, 'Test', 'right text';
is $dom.find('html > body > font > table > tr > td').[0].text, 'test1',
  'right text';
is $dom.find('html > body > font > table > tr > td').[1].text(:trim), 'test2',
  'right text';

done-testing;
