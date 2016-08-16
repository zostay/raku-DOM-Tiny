#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Case-insensitive attribute values
my $dom = DOM::Tiny.parse(q:to/EOF/);
<p class="foo">A</p>
<p class="foo bAr">B</p>
<p class="FOO">C</p>
EOF
is $dom.find('.foo').map(*.text).join(','),            'A,B', 'right result';
is $dom.find('.FOO').map(*.text).join(','),            'C',   'right result';
is $dom.find('[class=foo]').map(*.text).join(','),     'A',   'right result';
is $dom.find('[class=foo i]').map(*.text).join(','),   'A,C', 'right result';
is $dom.find('[class="foo" i]').map(*.text).join(','), 'A,C', 'right result';
is $dom.find('[class="foo bar"]').elems, 0, 'no results';
is $dom.find('[class="foo bar" i]').map(*.text).join(','), 'B',
  'right result';
is $dom.find('[class~=foo]').map(*.text).join(','), 'A,B', 'right result';
is $dom.find('[class~=foo i]').map(*.text).join(','), 'A,B,C',
  'right result';
is $dom.find('[class*=f]').map(*.text).join(','),   'A,B',   'right result';
is $dom.find('[class*=f i]').map(*.text).join(','), 'A,B,C', 'right result';
is $dom.find('[class^=F]').map(*.text).join(','),   'C',     'right result';
is $dom.find('[class^=F i]').map(*.text).join(','), 'A,B,C', 'right result';
is $dom.find('[class$=O]').map(*.text).join(','),   'C',     'right result';
is $dom.find('[class$=O i]').map(*.text).join(','), 'A,C',   'right result';

done-testing;
