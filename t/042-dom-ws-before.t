#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Whitespaces before closing bracket
my $dom = DOM::Tiny.parse('<div >content</div>');
ok $dom.at('div'), 'tag found';
is $dom.at('div').text,    'content', 'right text';
is $dom.at('div').content, 'content', 'right text';

done-testing;
