#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.parse('<div id="id" class="class">a</div>');
is $dom.at('div#id.class').text, 'a', 'right text';

done-testing;
