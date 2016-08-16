#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

is(DOM::Tiny.new.append-content('<p>').at('p').append-content('0').text,
  '0', 'right text');

done-testing;
