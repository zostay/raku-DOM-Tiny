#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

is(DOM::Tiny.new,                    '',    'right result');
is(DOM::Tiny.parse(''),              '',    'right result');
is(DOM::Tiny.new.parse(''),          '',    'right result');
is(DOM::Tiny.new.at('p'),            Nil,   'no result');
is(DOM::Tiny.new.append-content(''), '',    'right result');
is(DOM::Tiny.new.all-text,           '',    'right result');

done-testing;
