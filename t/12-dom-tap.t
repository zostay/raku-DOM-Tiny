#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.parse('<div id="a">A</div><div id="b">B</div>');
is-deeply $dom.find('[id]')».attr('id'), <a b>,
  'right result';
is { $dom.at('#b').remove; $dom }(), '<div id="a">A</div>',
  'right result';

done-testing;
