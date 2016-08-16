#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Attributes on multiple lines
my $dom = DOM::Tiny.parse("<div test=23 id='a' \n class='x' foo=bar />");
is $dom.at('div.x').attr('test'),        23,  'right attribute';
is $dom.at('[foo="bar"]').attr('class'), 'x', 'right attribute';
is $dom.at('div').attr(baz => Nil).root.Str,
  '<div baz class="x" foo="bar" id="a" test="23"></div>', 'right result';

done-testing
