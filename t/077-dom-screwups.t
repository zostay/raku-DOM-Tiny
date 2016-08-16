#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# A collection of wonderful screwups
my $dom = DOM::Tiny.parse(q:to/EOF/);
<!DOCTYPE html>
<html lang="en">
  <head><title>Wonderful Screwups</title></head>
  <body id="screw-up">
    <div>
      <div class="ewww">
        <a href="/test" target='_blank'><img src="/test.png"></a>
        <a href='/real bad' screwup: http://localhost/bad' target='_blank'>
          <img src="/test2.png">
      </div>
      </mt:If>
    </div>
    <b>>la<>la<<>>la<</b>
  </body>
</html>
EOF
is $dom.at('#screw-up > b').text, '>la<>la<<>>la<', 'right text';
is $dom.at('#screw-up .ewww > a > img').attr('src'), '/test.png',
  'right attribute';
is $dom.find('#screw-up .ewww > a > img').[1].attr('src'), '/test2.png',
  'right attribute';
is $dom.find('#screw-up .ewww > a > img').[2], Nil, 'no result';
is $dom.find('#screw-up .ewww > a > img').elems, 2, 'right number of elements';

done-testing;
