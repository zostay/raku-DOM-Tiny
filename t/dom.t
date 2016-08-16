#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# # Slash between attributes
# my $dom = DOM::Tiny.parse('<input /type=checkbox / value="/a/" checked/><br/>');
# is-deeply $dom.at('input').attr,
#   {type => 'checkbox', value => '/a/', checked => Nil}, 'right attributes';
# is "$dom", '<input checked type="checkbox" value="/a/"><br>', 'right result';
#
# # Dot and hash in class and id attributes
# my $dom = DOM::Tiny.parse('<p class="a#b.c">A</p><p id="a#b.c">B</p>');
# is $dom.at('p.a\#b\.c').text,       'A', 'right text';
# is $dom.at(':not(p.a\#b\.c)').text, 'B', 'right text';
# is $dom.at('p#a\#b\.c').text,       'B', 'right text';
# is $dom.at(':not(p#a\#b\.c)').text, 'A', 'right text';
#
# # Extra whitespace
# my $dom = DOM::Tiny.parse('< span>a< /span><b >b</b><span >c</ span>');
# is $dom.at('span').text,     'a', 'right text';
# is $dom.at('span + b').text, 'b', 'right text';
# is $dom.at('b + span').text, 'c', 'right text';
# is "$dom", '<span>a</span><b>b</b><span>c</span>', 'right result';
#
# # Selectors with leading and trailing whitespace
# my $dom = DOM::Tiny.parse('<div id=foo><b>works</b></div>');
# is $dom.at(' div   b ').text,          'works', 'right text';
# is $dom.at('  :not(  #foo  )  ').text, 'works', 'right text';
#
# # "0"
# my $dom = DOM::Tiny.parse('0');
# is "$dom", '0', 'right result';
# $dom.append_content('☃');
# is "$dom", '0☃', 'right result';
# is $dom.parse('<!DOCTYPE 0>'),  '<!DOCTYPE 0>',  'successful roundtrip';
# is $dom.parse('<!--0-->'),      '<!--0-->',      'successful roundtrip';
# is $dom.parse('<![CDATA[0]]>'), '<![CDATA[0]]>', 'successful roundtrip';
# is $dom.parse('<?0?>'),         '<?0?>',         'successful roundtrip';
#
# # Not self-closing
# my $dom = DOM::Tiny.parse('<div />< div ><pre />test</div >123');
# is $dom.at('div > div > pre').text, 'test', 'right text';
# is "$dom", '<div><div><pre>test</pre></div>123</div>', 'right result';
# my $dom = DOM::Tiny.parse('<p /><svg><circle /><circle /></svg>');
# is $dom.find('p > svg > circle').elems, 2, 'two circles';
# is "$dom", '<p><svg><circle></circle><circle></circle></svg></p>',
#   'right result';
#
# # "image"
# my $dom = DOM::Tiny.parse('<image src="foo.png">test');
# is $dom.at('img')<src>, 'foo.png', 'right attribute';
# is "$dom", '<img src="foo.png">test', 'right result';
#
# # "title"
# my $dom = DOM::Tiny.parse('<title> <p>test&lt;</title>');
# is $dom.at('title').text, ' <p>test<', 'right text';
# is "$dom", '<title> <p>test<</title>', 'right result';
#
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
