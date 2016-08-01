#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.parse(q:to/EOF/);
<body>
  <div>test1</div>
  <div><div>test2</div></div>
<body>
EOF
is $dom.find('body > div')[0].text, 'test1', 'right text';
is $dom.find('body > div')[1].text, '',      'no content';
is $dom.find('body > div')[2], Nil, 'no result';
is $dom.find('body > div').elems, 2, 'right number of elements';
is $dom.find('body > div > div')[0].text, 'test2', 'right text';
is $dom.find('body > div > div')[1], Nil, 'no result';
is $dom.find('body > div > div').elems, 1, 'right number of elements';

done-testing;
