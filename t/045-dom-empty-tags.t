#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Empty tags
my $dom = DOM::Tiny.parse('<hr /><br/><br id="br"/><br />');
is "$dom", '<hr><br><br id="br"><br>', 'right result';
is $dom.at('br').content, '', 'empty result';

done-testing;
