#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Find attribute with hyphen in name and value
my $dom = DOM::Tiny.parse(q:to/EOF/);
<html>
  <head><meta http-equiv="content-type" content="text/html"></head>
</html>
EOF
is $dom.find('[http-equiv]').[0]<content>, 'text/html', 'right attribute';
is $dom.find('[http-equiv]').[1], Nil, 'no result';
is $dom.find('[http-equiv="content-type"]').[0]<content>, 'text/html',
  'right attribute';
is $dom.find('[http-equiv="content-type"]').[1], Nil, 'no result';
is $dom.find('[http-equiv^="content-"]').[0]<content>, 'text/html',
  'right attribute';
is $dom.find('[http-equiv^="content-"]').[1], Nil, 'no result';
is $dom.find('head > [http-equiv$="-type"]').[0]<content>, 'text/html',
  'right attribute';
is $dom.find('head > [http-equiv$="-type"]').[1], Nil, 'no result';

done-testing;
