#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

plan 3;

class MyDOM is DOM::Tiny {
    method color(MyDOM:D:) { self.attr('color') }
}

my $dom = MyDOM.parse('<p color="red">');
isa-ok $dom, MyDOM, 'custom class is MyDOM';
isa-ok $dom, DOM::Tiny, 'custom class is DOM::Tiny';
is $dom.at('p').color, 'red', 'custom method works';
