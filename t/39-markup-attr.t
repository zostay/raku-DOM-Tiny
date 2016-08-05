#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Markup characters in attribute values
my $dom = DOM::Tiny.parse(qq{<div id="<a>" \n test='='>Test<div id='><' /></div>});
is $dom.at('div[id="<a>"]').attr<test>, '=', 'right attribute';
is $dom.at('[id="<a>"]').text, 'Test', 'right text';
is $dom.at('[id="><"]').attr<id>, '><', 'right attribute';

done-testing;
