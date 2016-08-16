#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# And another broken "font" block
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head><title>Test</title></head>
  <body>
    <table>
      <tr>
        <td><font><br>te<br>st<br>1</td></font>
        <td>x1<td><img>tes<br>t2</td>
        <td>x2<td><font>t<br>est3</font></td>
      </tr>
    </table>
  </body>
</html>
EOF
is $dom.at('html > head > title').text, 'Test', 'right text';
is $dom.find('html body table tr > td > font').[0].text, 'te st 1',
  'right text';
is $dom.find('html body table tr > td').[1].text, 'x1',     'right text';
is $dom.find('html body table tr > td').[2].text, 'tes t2', 'right text';
is $dom.find('html body table tr > td').[3].text, 'x2',     'right text';
is $dom.find('html body table tr > td').[5], Nil, 'no result';
is $dom.find('html body table tr > td').elems, 5, 'right number of elements';
is $dom.find('html body table tr > td > font').[1].text, 't est3',
  'right text';
is $dom.find('html body table tr > td > font').[2], Nil, 'no result';
is $dom.find('html body table tr > td > font').elems, 2,
  'right number of elements';
is $dom, q:to/EOF/, 'right result';
<html>
  <head><title>Test</title></head>
  <body>
    <table>
      <tr>
        <td><font><br>te<br>st<br>1</font></td>
        <td>x1</td><td><img>tes<br>t2</td>
        <td>x2</td><td><font>t<br>est3</font></td>
      </tr>
    </table>
  </body>
</html>
EOF

done-testing;
