#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Dots
my $dom = DOM::Tiny.parse(q:to/EOF/);
<?xml version="1.0"?>
<foo xmlns:foo.bar="uri:first">
  <bar xmlns:fooxbar="uri:second">
    <foo.bar:baz>First</fooxbar:baz>
    <fooxbar:ya.da>Second</foo.bar:ya.da>
  </bar>
</foo>
EOF
is $dom.at('foo bar baz').text(:trim),    'First',      'right text';
is $dom.at('baz').namespace,       'uri:first',  'right namespace';
is $dom.at('foo bar ya\.da').text(:trim), 'Second',     'right text';
is $dom.at('ya\.da').namespace,    'uri:second', 'right namespace';
is $dom.at('foo').namespace,       Str,        'no namespace';
is $dom.at('[xml\.s]'), Nil, 'no result';
is $dom.at('b\.z'),     Nil, 'no result';

done-testing;
