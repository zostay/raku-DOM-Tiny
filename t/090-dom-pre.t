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
is $dom.text(:trim), '', 'no text';
is $dom.text, "\n", 'right text';
is $dom.all-text(:trim), "looks like\n  it\n    really\n  works", 'right text';
is $dom.all-text, "\n  looks\n  like\n  it\n    really\n  \n  works\n\n",
  'right text';
is $dom.at('div').text(:trim), 'looks works', 'right text';
is $dom.at('div').text, "\n  looks\n  \n  works\n", 'right text';
is $dom.at('div').all-text(:trim), "looks like\n  it\n    really\n  works",
  'right text';
is $dom.at('div').all-text,
  "\n  looks\n  like\n  it\n    really\n  \n  works\n", 'right text';
is $dom.at('div pre').text(:trim), "\n  ", 'right text';
is $dom.at('div pre').text, "\n  ", 'right text';
is $dom.at('div pre').all-text(:trim), "like\n  it\n    really\n  ", 'right text';
is $dom.at('div pre').all-text, "like\n  it\n    really\n  ", 'right text';
is $dom.at('div pre code').text(:trim), "like\n  it\n    really", 'right text';
is $dom.at('div pre code').text, "like\n  it\n    really", 'right text';
is $dom.at('div pre code').all-text(:trim), "like\n  it\n    really", 'right text';
is $dom.at('div pre code').all-text, "like\n  it\n    really",
  'right text';

done-testing;
