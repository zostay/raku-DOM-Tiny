#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Namespace
my $dom = DOM::Tiny.parse(q:to/EOF/);
<?xml version="1.0"?>
<bk:book xmlns='uri:default-ns'
         xmlns:bk='uri:book-ns'
         xmlns:isbn='uri:isbn-ns'>
  <bk:title>Programming Perl</bk:title>
  <comment>rocks!</comment>
  <nons xmlns=''>
    <section>Nothing</section>
  </nons>
  <meta xmlns='uri:meta-ns'>
    <isbn:number>978-0596000271</isbn:number>
  </meta>
</bk:book>
EOF
ok $dom.xml, 'XML mode detected';
is $dom.namespace, Nil, 'no namespace';
is $dom.at('book comment').namespace, 'uri:default-ns', 'right namespace';
is $dom.at('book comment').text,      'rocks!',         'right text';
is $dom.at('book nons section').namespace, '',            'no namespace';
is $dom.at('book nons section').text,      'Nothing',     'right text';
is $dom.at('book meta number').namespace,  'uri:isbn-ns', 'right namespace';
is $dom.at('book meta number').text, '978-0596000271', 'right text';
is $dom.children('bk\:book').first<xmlns>, 'uri:default-ns',
  'right attribute';
is $dom.children('book').first<xmlns>, 'uri:default-ns', 'right attribute';
is $dom.children('k\:book').first, Nil, 'no result';
is $dom.children('ook').first,     Nil, 'no result';
is $dom.at('k\:book'), Nil, 'no result';
is $dom.at('ook'),     Nil, 'no result';
is $dom.at('[xmlns\:bk]')<xmlns:bk>, 'uri:book-ns', 'right attribute';
is $dom.at('[bk]')<xmlns:bk>,        'uri:book-ns', 'right attribute';
is $dom.at('[bk]').attr('xmlns:bk'), 'uri:book-ns', 'right attribute';
is $dom.at('[bk]').attr('s:bk'),     Str,         'no attribute';
is $dom.at('[bk]').attr('bk'),       Str,         'no attribute';
is $dom.at('[bk]').attr('k'),        Str,         'no attribute';
is $dom.at('[s\:bk]'), Nil, 'no result';
is $dom.at('[k]'),     Nil, 'no result';
is $dom.at('number').ancestors('meta').first<xmlns>, 'uri:meta-ns',
  'right attribute';
ok $dom.at('nons').matches('book > nons'), 'element did match';
ok !$dom.at('title').matches('book > nons > section'),
  'element did not match';

done-testing;
