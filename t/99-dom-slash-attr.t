#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Slash between attributes
my $dom = DOM::Tiny.parse('<input /type=checkbox / value="/a/" checked/><br/>');
is-deeply $dom.at('input').attr,
  {type => 'checkbox', value => '/a/', checked => Nil}, 'right attributes';
is "$dom", '<input checked type="checkbox" value="/a/"><br>', 'right result';

done-testing;
