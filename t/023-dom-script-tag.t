#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Script tag
my $dom = DOM::Tiny.parse(q:to/EOF/);
<script charset="utf-8">alert('lalala');</script>
EOF
is $dom.at('script').text, "alert('lalala');", 'right script content';

done-testing;
