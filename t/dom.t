#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# # "textarea"
# my $dom = DOM::Tiny.parse('<textarea id="a"> <p>test&lt;</textarea>');
# is $dom.at('textarea#a').text, ' <p>test<', 'right text';
# is "$dom", '<textarea id="a"> <p>test<</textarea>', 'right result';
#
# # Comments
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <!-- HTML5 -->
# <!-- bad idea -- HTML5 -->
# <!-- HTML4 -- >
# <!-- bad idea -- HTML4 -- >
# EOF
# is $dom.tree.[1][1], ' HTML5 ',             'right comment';
# is $dom.tree.[3][1], ' bad idea -- HTML5 ', 'right comment';
# is $dom.tree.[5][1], ' HTML4 ',             'right comment';
# is $dom.tree.[7][1], ' bad idea -- HTML4 ', 'right comment';
#
# SKIP: {
#   skip 'Regex subexpression recursion causes SIGSEGV on 5.8', 1 unless $] >= 5.010000;
#   # Huge number of attributes
#   $dom = DOM::Tiny.parse('<div ' . ('a=b ' x 32768) . '>Test</div>');
#   is $dom.at('div[a=b]').text, 'Test', 'right text';
# }
#
# # Huge number of nested tags
# my $huge = ('<a>' x 100) . 'works' . ('</a>' x 100);
# my $dom = DOM::Tiny.parse($huge);
# is $dom.all-text, 'works', 'right text';
# is "$dom", $huge, 'right result';
#
# # TO_JSON
# is +JSON::PP.new.convert_blessed.encode([DOM::Tiny.parse('<a></a>')]), '["<a></a>"]', 'right result';

done-testing;
