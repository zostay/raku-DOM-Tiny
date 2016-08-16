#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Preformatted text
my $dom = DOM::Tiny.parse(q:to/EOF/);
<div>
  looks
  <pre><code>like
  it
    really</code>
  </pre>
  works
</div>
EOF
is $dom.text, '', 'no text';
is $dom.text(:!trim), "\n", 'right text';
is $dom.all-text, "looks like\n  it\n    really\n  works", 'right text';
is $dom.all-text(:!trim), "\n  looks\n  like\n  it\n    really\n  \n  works\n\n",
  'right text';
is $dom.at('div').text, 'looks works', 'right text';
is $dom.at('div').text(:!trim), "\n  looks\n  \n  works\n", 'right text';
is $dom.at('div').all-text, "looks like\n  it\n    really\n  works",
  'right text';
is $dom.at('div').all-text(:!trim),
  "\n  looks\n  like\n  it\n    really\n  \n  works\n", 'right text';
is $dom.at('div pre').text, "\n  ", 'right text';
is $dom.at('div pre').text(:!trim), "\n  ", 'right text';
is $dom.at('div pre').all-text, "like\n  it\n    really\n  ", 'right text';
is $dom.at('div pre').all-text(:!trim), "like\n  it\n    really\n  ", 'right text';
is $dom.at('div pre code').text, "like\n  it\n    really", 'right text';
is $dom.at('div pre code').text(:!trim), "like\n  it\n    really", 'right text';
is $dom.at('div pre code').all-text, "like\n  it\n    really", 'right text';
is $dom.at('div pre code').all-text(:!trim), "like\n  it\n    really",
  'right text';

done-testing;
