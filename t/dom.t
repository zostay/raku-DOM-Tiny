#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# # Real world JavaScript and CSS
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <html>
#   <head>
#     <style test=works>#style { foo: style('<test>'); }</style>
#     <script>
#       if (a < b) {
#         alert('<123>');
#       }
#     </script>
#     < sCriPt two="23" >if (b > c) { alert('&<ohoh>') }< / scRiPt >
#   <body>Foo!</body>
# EOF
# is $dom.find('html > body').[0].text, 'Foo!', 'right text';
# is $dom.find('html > head > style').[0].text,
#   "#style \{ foo: style('<test>'); }", 'right text';
# is $dom.find('html > head > script').[0].text,
#   "\n      if (a < b) \{\n        alert('<123>');\n      }\n    ", 'right text';
# is $dom.find('html > head > script').[1].text,
#   "if (b > c) \{ alert('&<ohoh>') }", 'right text';
#
# # More real world JavaScript
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <!DOCTYPE html>
# <html>
#   <head>
#     <title>Foo</title>
#     <script src="/js/one.js"></script>
#     <script src="/js/two.js"></script>
#     <script src="/js/three.js"></script>
#   </head>
#   <body>Bar</body>
# </html>
# EOF
# is $dom.at('title').text, 'Foo', 'right text';
# is $dom.find('html > head > script').[0].attr('src'), '/js/one.js',
#   'right attribute';
# is $dom.find('html > head > script').[1].attr('src'), '/js/two.js',
#   'right attribute';
# is $dom.find('html > head > script').[2].attr('src'), '/js/three.js',
#   'right attribute';
# is $dom.find('html > head > script').[2].text, '', 'no text';
# is $dom.at('html > body').text, 'Bar', 'right text';
#
# # Even more real world JavaScript
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <!DOCTYPE html>
# <html>
#   <head>
#     <title>Foo</title>
#     <script src="/js/one.js"></script>
#     <script src="/js/two.js"></script>
#     <script src="/js/three.js">
#   </head>
#   <body>Bar</body>
# </html>
# EOF
# is $dom.at('title').text, 'Foo', 'right text';
# is $dom.find('html > head > script').[0].attr('src'), '/js/one.js',
#   'right attribute';
# is $dom.find('html > head > script').[1].attr('src'), '/js/two.js',
#   'right attribute';
# is $dom.find('html > head > script').[2].attr('src'), '/js/three.js',
#   'right attribute';
# is $dom.find('html > head > script').[2].text, '', 'no text';
# is $dom.at('html > body').text, 'Bar', 'right text';
#
# # Inline DTD
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <?xml version="1.0"?>
# <!-- This is a Test! -->
# <!DOCTYPE root [
#   <!ELEMENT root (#PCDATA)>
#   <!ATTLIST root att CDATA #REQUIRED>
# ]>
# <root att="test">
#   <![CDATA[<hello>world</hello>]]>
# </root>
# EOF
# ok $dom.xml, 'XML mode detected';
# is $dom.at('root').attr('att'), 'test', 'right attribute';
# is $dom.tree.[5][1], ' root [
#   <!ELEMENT root (#PCDATA)>
#   <!ATTLIST root att CDATA #REQUIRED>
# ]', 'right doctype';
# is $dom.at('root').text, '<hello>world</hello>', 'right text';
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <!doctype book
# SYSTEM "usr.dtd"
# [
#   <!ENTITY test "yeah">
# ]>
# <foo />
# EOF
# is $dom.tree.[1][1], ' book
# SYSTEM "usr.dtd"
# [
#   <!ENTITY test "yeah">
# ]', 'right doctype';
# ok !$dom.xml, 'XML mode not detected';
# is $dom.at('foo'), '<foo></foo>', 'right element';
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <?xml version="1.0" encoding = 'utf-8'?>
# <!DOCTYPE foo [
#   <!ELEMENT foo ANY>
#   <!ATTLIST foo xml:lang CDATA #IMPLIED>
#   <!ENTITY % e SYSTEM "myentities.ent">
#   %myentities;
# ]  >
# <foo xml:lang="de">Check!</fOo>
# EOF
# ok $dom.xml, 'XML mode detected';
# is $dom.tree.[3][1], ' foo [
#   <!ELEMENT foo ANY>
#   <!ATTLIST foo xml:lang CDATA #IMPLIED>
#   <!ENTITY % e SYSTEM "myentities.ent">
#   %myentities;
# ]  ', 'right doctype';
# is $dom.at('foo').attr.{'xml:lang'}, 'de', 'right attribute';
# is $dom.at('foo').text, 'Check!', 'right text';
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <!DOCTYPE TESTSUITE PUBLIC "my.dtd" 'mhhh' [
#   <!ELEMENT foo ANY>
#   <!ATTLIST foo bar ENTITY 'true'>
#   <!ENTITY system_entities SYSTEM 'systems.xml'>
#   <!ENTITY leertaste '&#32;'>
#   <!-- This is a comment -->
#   <!NOTATION hmmm SYSTEM "hmmm">
# ]   >
# <?check for-nothing?>
# <foo bar='false'>&leertaste;!!!</foo>
# EOF
# is $dom.tree.[1][1], ' TESTSUITE PUBLIC "my.dtd" \'mhhh\' [
#   <!ELEMENT foo ANY>
#   <!ATTLIST foo bar ENTITY \'true\'>
#   <!ENTITY system_entities SYSTEM \'systems.xml\'>
#   <!ENTITY leertaste \'&#32;\'>
#   <!-- This is a comment -->
#   <!NOTATION hmmm SYSTEM "hmmm">
# ]   ', 'right doctype';
# is $dom.at('foo').attr('bar'), 'false', 'right attribute';
#
# # Broken "font" block and useless end tags
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <html>
#   <head><title>Test</title></head>
#   <body>
#     <table>
#       <tr><td><font>test</td></font></tr>
#       </tr>
#     </table>
#   </body>
# </html>
# EOF
# is $dom.at('html > head > title').text,          'Test', 'right text';
# is $dom.at('html body table tr td > font').text, 'test', 'right text';
#
# # Different broken "font" block
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <html>
#   <head><title>Test</title></head>
#   <body>
#     <font>
#     <table>
#       <tr>
#         <td>test1<br></td></font>
#         <td>test2<br>
#     </table>
#   </body>
# </html>
# EOF
# is $dom.at('html > head > title').text, 'Test', 'right text';
# is $dom.find('html > body > font > table > tr > td').[0].text, 'test1',
#   'right text';
# is $dom.find('html > body > font > table > tr > td').[1].text, 'test2',
#   'right text';
#
# # Broken "font" and "div" blocks
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <html>
#   <head><title>Test</title></head>
#   <body>
#     <font>
#     <div>test1<br>
#       <div>test2<br></font>
#     </div>
#   </body>
# </html>
# EOF
# is $dom.at('html head title').text,            'Test',  'right text';
# is $dom.at('html body font > div').text,       'test1', 'right text';
# is $dom.at('html body font > div > div').text, 'test2', 'right text';
#
# # Broken "div" blocks
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <html>
#   <head><title>Test</title></head>
#   <body>
#     <div>
#     <table>
#       <tr><td><div>test</td></div></tr>
#       </div>
#     </table>
#   </body>
# </html>
# EOF
# is $dom.at('html head title').text,                 'Test', 'right text';
# is $dom.at('html body div table tr td > div').text, 'test', 'right text';
#
# # And another broken "font" block
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <html>
#   <head><title>Test</title></head>
#   <body>
#     <table>
#       <tr>
#         <td><font><br>te<br>st<br>1</td></font>
#         <td>x1<td><img>tes<br>t2</td>
#         <td>x2<td><font>t<br>est3</font></td>
#       </tr>
#     </table>
#   </body>
# </html>
# EOF
# is $dom.at('html > head > title').text, 'Test', 'right text';
# is $dom.find('html body table tr > td > font').[0].text, 'te st 1',
#   'right text';
# is $dom.find('html body table tr > td').[1].text, 'x1',     'right text';
# is $dom.find('html body table tr > td').[2].text, 'tes t2', 'right text';
# is $dom.find('html body table tr > td').[3].text, 'x2',     'right text';
# is $dom.find('html body table tr > td').[5], Nil, 'no result';
# is $dom.find('html body table tr > td').size, 5, 'right number of elements';
# is $dom.find('html body table tr > td > font').[1].text, 't est3',
#   'right text';
# is $dom.find('html body table tr > td > font').[2], Nil, 'no result';
# is $dom.find('html body table tr > td > font').size, 2,
#   'right number of elements';
# is $dom, q:to/EOF/, 'right result';
# <html>
#   <head><title>Test</title></head>
#   <body>
#     <table>
#       <tr>
#         <td><font><br>te<br>st<br>1</font></td>
#         <td>x1</td><td><img>tes<br>t2</td>
#         <td>x2</td><td><font>t<br>est3</font></td>
#       </tr>
#     </table>
#   </body>
# </html>
# EOF
#
# # A collection of wonderful screwups
# my $dom = DOM::Tiny.parse(<<'EOF');
# <!DOCTYPE html>
# <html lang="en">
#   <head><title>Wonderful Screwups</title></head>
#   <body id="screw-up">
#     <div>
#       <div class="ewww">
#         <a href="/test" target='_blank'><img src="/test.png"></a>
#         <a href='/real bad' screwup: http://localhost/bad' target='_blank'>
#           <img src="/test2.png">
#       </div>
#       </mt:If>
#     </div>
#     <b>>la<>la<<>>la<</b>
#   </body>
# </html>
# EOF
# is $dom.at('#screw-up > b').text, '>la<>la<<>>la<', 'right text';
# is $dom.at('#screw-up .ewww > a > img').attr('src'), '/test.png',
#   'right attribute';
# is $dom.find('#screw-up .ewww > a > img').[1].attr('src'), '/test2.png',
#   'right attribute';
# is $dom.find('#screw-up .ewww > a > img').[2], Nil, 'no result';
# is $dom.find('#screw-up .ewww > a > img').size, 2, 'right number of elements';
#
# # Broken "br" tag
# my $dom = DOM::Tiny.parse('<br< abc abc abc abc abc abc abc abc<p>Test</p>');
# is $dom.at('p').text, 'Test', 'right text';
#
# # Modifying an XML document
# my $dom = DOM::Tiny.parse(<<'EOF');
# <?xml version='1.0' encoding='UTF-8'?>
# <XMLTest />
# EOF
# ok $dom.xml, 'XML mode detected';
# $dom.at('XMLTest').content('<Element />');
# my $element = $dom.at('Element');
# is $element.tag, 'Element', 'right tag';
# ok $element.xml, 'XML mode active';
# $element = $dom.at('XMLTest').children.[0];
# is $element.tag, 'Element', 'right child';
# is $element.parent.tag, 'XMLTest', 'right parent';
# ok $element.root.xml, 'XML mode active';
# $dom.replace('<XMLTest2 /><XMLTest3 just="works" />');
# ok $dom.xml, 'XML mode active';
# $dom.at('XMLTest2')<foo> = Nil;
# is $dom, '<XMLTest2 foo="foo" /><XMLTest3 just="works" />', 'right result';
#
# # Ensure HTML semantics
# ok !DOM::Tiny.new.xml(Nil).parse('<?xml version="1.0"?>').xml,
#   'XML mode not detected';
# $dom
#   = DOM::Tiny.new.xml(0).parse('<?xml version="1.0"?><br><div>Test</div>');
# is $dom.at('div:root').text, 'Test', 'right text';
#
# # Ensure XML semantics
# ok !!DOM::Tiny.new.xml(1).parse('<foo />').xml, 'XML mode active';
# my $dom = DOM::Tiny.parse(<<'EOF');
# <?xml version='1.0' encoding='UTF-8'?>
# <script>
#   <table>
#     <td>
#       <tr><thead>foo<thead></tr>
#     </td>
#     <td>
#       <tr><thead>bar<thead></tr>
#     </td>
#   </table>
# </script>
# EOF
# is $dom.find('table > td > tr > thead').[0].text, 'foo', 'right text';
# is $dom.find('script > table > td > tr > thead').[1].text, 'bar',
#   'right text';
# is $dom.find('table > td > tr > thead').[2], Nil, 'no result';
# is $dom.find('table > td > tr > thead').size, 2, 'right number of elements';
#
# # Ensure XML semantics again
# my $dom = DOM::Tiny.new.xml(1).parse(<<'EOF');
# <table>
#   <td>
#     <tr><thead>foo<thead></tr>
#   </td>
#   <td>
#     <tr><thead>bar<thead></tr>
#   </td>
# </table>
# EOF
# is $dom.find('table > td > tr > thead').[0].text, 'foo', 'right text';
# is $dom.find('table > td > tr > thead').[1].text, 'bar', 'right text';
# is $dom.find('table > td > tr > thead').[2], Nil, 'no result';
# is $dom.find('table > td > tr > thead').size, 2, 'right number of elements';
#
# # Nested tables
# my $dom = DOM::Tiny.parse(<<'EOF');
# <table id="foo">
#   <tr>
#     <td>
#       <table id="bar">
#         <tr>
#           <td>baz</td>
#         </tr>
#       </table>
#     </td>
#   </tr>
# </table>
# EOF
# is $dom.find('#foo > tr > td > #bar > tr >td').[0].text, 'baz', 'right text';
# is $dom.find('table > tr > td > table > tr >td').[0].text, 'baz',
#   'right text';
#
# # Nested find
# $dom.parse(q:to/EOF/);
# <c>
#   <a>foo</a>
#   <b>
#     <a>bar</a>
#     <c>
#       <a>baz</a>
#       <d>
#         <a>yada</a>
#       </d>
#     </c>
#   </b>
# </c>
# EOF
# my @results = $dom.find('b').map({ .find('a').map({ .text }) }).flat;
# is-deeply @results, <bar baz yada>, 'right results';
# @results = $dom.find('a').map({ .text });
# is-deeply @results, <foo bar baz yada>, 'right results';
# @results = $dom.find('b').map({ .find('c a').map({ .text }) }).flat;
# is-deeply @results, <baz yada>, 'right results';
# is $dom.at('b').at('a').text, 'bar', 'right text';
# is $dom.at('c > b > a').text, 'bar', 'right text';
# is $dom.at('b').at('c > b > a'), Nil, 'no result';
#
# # Direct hash access to attributes in XML mode
# my $dom = DOM::Tiny.new.xml(1).parse(q:to/EOF/);
# <a id="one">
#   <B class="two" test>
#     foo
#     <c id="three">bar</c>
#     <c ID="four">baz</c>
#   </B>
# </a>
# EOF
# ok $dom.xml, 'XML mode active';
# is $dom.at('a')<id>, 'one', 'right attribute';
# is-deeply [sort keys %{$dom.at('a')}], ['id'], 'right attributes';
# is $dom.at('a').at('B').text, 'foo', 'right text';
# is $dom.at('B')<class>, 'two', 'right attribute';
# is-deeply [sort keys %{$dom.at('a B')}], <class test>, 'right attributes';
# is $dom.find('a B c').[0].text, 'bar', 'right text';
# is $dom.find('a B c').[0]{id}, 'three', 'right attribute';
# is-deeply [sort keys %{$dom.find('a B c').[0]}], ['id'], 'right attributes';
# is $dom.find('a B c').[1].text, 'baz', 'right text';
# is $dom.find('a B c').[1]{ID}, 'four', 'right attribute';
# is-deeply [sort keys %{$dom.find('a B c').[1]}], ['ID'], 'right attributes';
# is $dom.find('a B c').[2], Nil, 'no result';
# is $dom.find('a B c').size, 2, 'right number of elements';
# @results = $dom.find('a B c').map({ .text });
# is-deeply @results, <bar baz>, 'right results';
# is $dom.find('a B c').join("\n"),
#   qq{<c id="three">bar</c>\n<c ID="four">baz</c>}, 'right result';
# is-deeply [keys %$dom], [], 'root has no attributes';
# is $dom.find('#nothing').join, '', 'no result';
#
# # Direct hash access to attributes in HTML mode
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <a id="one">
#   <B class="two" test>
#     foo
#     <c id="three">bar</c>
#     <c ID="four">baz</c>
#   </B>
# </a>
# EOF
# ok !$dom.xml, 'XML mode not active';
# is $dom.at('a')<id>, 'one', 'right attribute';
# is-deeply [sort keys %{$dom.at('a')}], ['id'], 'right attributes';
# is $dom.at('a').at('b').text, 'foo', 'right text';
# is $dom.at('b')<class>, 'two', 'right attribute';
# is-deeply [sort keys %{$dom.at('a b')}], <class test>, 'right attributes';
# is $dom.find('a b c').[0].text, 'bar', 'right text';
# is $dom.find('a b c').[0]{id}, 'three', 'right attribute';
# is-deeply [sort keys %{$dom.find('a b c').[0]}], ['id'], 'right attributes';
# is $dom.find('a b c').[1].text, 'baz', 'right text';
# is $dom.find('a b c').[1]{id}, 'four', 'right attribute';
# is-deeply [sort keys %{$dom.find('a b c').[1]}], ['id'], 'right attributes';
# is $dom.find('a b c').[2], Nil, 'no result';
# is $dom.find('a b c').size, 2, 'right number of elements';
# @results = $dom.find('a b c').map({ .text });
# is-deeply @results, <bar baz>, 'right results';
# is $dom.find('a b c').join("\n"),
#   qq{<c id="three">bar</c>\n<c id="four">baz</c>}, 'right result';
# is-deeply [keys %$dom], [], 'root has no attributes';
# is $dom.find('#nothing').join, '', 'no result';
#
# # Append and prepend content
# my $dom = DOM::Tiny.parse('<a><b>Test<c /></b></a>');
# $dom.at('b').append_content('<d />');
# is $dom.children.[0].tag, 'a', 'right tag';
# is $dom.all-text, 'Test', 'right text';
# is $dom.at('c').parent.tag, 'b', 'right tag';
# is $dom.at('d').parent.tag, 'b', 'right tag';
# $dom.at('b').prepend_content('<e>DOM</e>');
# is $dom.at('e').parent.tag, 'b', 'right tag';
# is $dom.all-text, 'DOM Test', 'right text';
#
# # Wrap elements
# my $dom = DOM::Tiny.parse('<a>Test</a>');
# is "$dom", '<a>Test</a>', 'right result';
# is $dom.wrap('<b></b>').type, 'root', 'right type';
# is "$dom", '<a>Test</a>', 'no changes';
# is $dom.at('a').wrap('<b></b>').type, 'tag', 'right type';
# is "$dom", '<b><a>Test</a></b>', 'right result';
# is $dom.at('b').strip.at('a').wrap('A').tag, 'a', 'right tag';
# is "$dom", '<a>Test</a>', 'right result';
# is $dom.at('a').wrap('<b></b>').tag, 'a', 'right tag';
# is "$dom", '<b><a>Test</a></b>', 'right result';
# is $dom.at('a').wrap('C<c><d>D</d><e>E</e></c>F').parent.tag, 'd',
#   'right tag';
# is "$dom", '<b>C<c><d>D<a>Test</a></d><e>E</e></c>F</b>', 'right result';
#
# # Wrap content
# my $dom = DOM::Tiny.parse('<a>Test</a>');
# is $dom.at('a').wrap_content('A').tag, 'a', 'right tag';
# is "$dom", '<a>Test</a>', 'right result';
# is $dom.wrap_content('<b></b>').type, 'root', 'right type';
# is "$dom", '<b><a>Test</a></b>', 'right result';
# is $dom.at('b').strip.at('a').tag('e:a').wrap_content('1<b c="d"></b>')
#   .tag, 'e:a', 'right tag';
# is "$dom", '<e:a>1<b c="d">Test</b></e:a>', 'right result';
# is $dom.at('a').wrap_content('C<c><d>D</d><e>E</e></c>F').parent.type,
#   'root', 'right type';
# is "$dom", '<e:a>C<c><d>D1<b c="d">Test</b></d><e>E</e></c>F</e:a>',
#   'right result';
#
# # Broken "div" in "td"
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <table>
#   <tr>
#     <td><div id="A"></td>
#     <td><div id="B"></td>
#   </tr>
# </table>
# EOF
# is $dom.find('table tr td').[0].at('div')<id>, 'A', 'right attribute';
# is $dom.find('table tr td').[1].at('div')<id>, 'B', 'right attribute';
# is $dom.find('table tr td').[2], Nil, 'no result';
# is $dom.find('table tr td').size, 2, 'right number of elements';
# is "$dom", q:to/EOF/, 'right result';
# <table>
#   <tr>
#     <td><div id="A"></div></td>
#     <td><div id="B"></div></td>
#   </tr>
# </table>
# EOF
#
# # Preformatted text
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <div>
#   looks
#   <pre><code>like
#   it
#     really</code>
#   </pre>
#   works
# </div>
# EOF
# is $dom.text, '', 'no text';
# is $dom.text(0), "\n", 'right text';
# is $dom.all-text, "looks like\n  it\n    really\n  works", 'right text';
# is $dom.all-text(0), "\n  looks\n  like\n  it\n    really\n  \n  works\n\n",
#   'right text';
# is $dom.at('div').text, 'looks works', 'right text';
# is $dom.at('div').text(0), "\n  looks\n  \n  works\n", 'right text';
# is $dom.at('div').all-text, "looks like\n  it\n    really\n  works",
#   'right text';
# is $dom.at('div').all-text(0),
#   "\n  looks\n  like\n  it\n    really\n  \n  works\n", 'right text';
# is $dom.at('div pre').text, "\n  ", 'right text';
# is $dom.at('div pre').text(0), "\n  ", 'right text';
# is $dom.at('div pre').all-text, "like\n  it\n    really\n  ", 'right text';
# is $dom.at('div pre').all-text(0), "like\n  it\n    really\n  ", 'right text';
# is $dom.at('div pre code').text, "like\n  it\n    really", 'right text';
# is $dom.at('div pre code').text(0), "like\n  it\n    really", 'right text';
# is $dom.at('div pre code').all-text, "like\n  it\n    really", 'right text';
# is $dom.at('div pre code').all-text(0), "like\n  it\n    really",
#   'right text';
#
# # Form values
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <form action="/foo">
#   <p>Test</p>
#   <input type="text" name="a" value="A" />
#   <input type="checkbox" name="q">
#   <input type="checkbox" checked name="b" value="B">
#   <input type="radio" name="r">
#   <input type="radio" checked name="c" value="C">
#   <input name="s">
#   <input type="checkbox" name="t" value="">
#   <input type=text name="u">
#   <select multiple name="f">
#     <option value="F">G</option>
#     <optgroup>
#       <option>H</option>
#       <option selected>I</option>
#     </optgroup>
#     <option value="J" selected>K</option>
#   </select>
#   <select name="n"><option>N</option></select>
#   <select multiple name="q"><option>Q</option></select>
#   <select name="d">
#     <option selected>R</option>
#     <option selected>D</option>
#   </select>
#   <textarea name="m">M</textarea>
#   <button name="o" value="O">No!</button>
#   <input type="submit" name="p" value="P" />
# </form>
# EOF
# is $dom.at('p').val,                         Nil, 'no value';
# is $dom.at('input').val,                     'A',   'right value';
# is $dom.at('input:checked').val,             'B',   'right value';
# is $dom.at('input:checked[type=radio]').val, 'C',   'right value';
# is-deeply $dom.at('select').val, ['I', 'J'], 'right values';
# is $dom.at('select option').val,                          'F', 'right value';
# is $dom.at('select optgroup option:not([selected])').val, 'H', 'right value';
# is $dom.find('select').[1].at('option').val, 'N', 'right value';
# is $dom.find('select').[1].val,        Nil, 'no value';
# is-deeply $dom.find('select').[2].val, Nil, 'no value';
# is $dom.find('select').[2].at('option').val, 'Q', 'right value';
# is-deeply $dom.find('select').last.val, 'D', 'right value';
# is-deeply $dom.find('select').last.at('option').val, 'R', 'right value';
# is $dom.at('textarea').val, 'M', 'right value';
# is $dom.at('button').val,   'O', 'right value';
# is $dom.find('form input').last.val, 'P', 'right value';
# is $dom.at('input[name=q]').val, 'on',  'right value';
# is $dom.at('input[name=r]').val, 'on',  'right value';
# is $dom.at('input[name=s]').val, Nil, 'no value';
# is $dom.at('input[name=t]').val, '',    'right value';
# is $dom.at('input[name=u]').val, Nil, 'no value';
#
# # PoCo example with whitespace sensitive text
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <?xml version="1.0" encoding="UTF-8"?>
# <response>
#   <entry>
#     <id>1286823</id>
#     <displayName>Homer Simpson</displayName>
#     <addresses>
#       <type>home</type>
#       <formatted><![CDATA[742 Evergreen Terrace
# Springfield, VT 12345 USA]]></formatted>
#     </addresses>
#   </entry>
#   <entry>
#     <id>1286822</id>
#     <displayName>Marge Simpson</displayName>
#     <addresses>
#       <type>home</type>
#       <formatted>742 Evergreen Terrace
# Springfield, VT 12345 USA</formatted>
#     </addresses>
#   </entry>
# </response>
# EOF
# is $dom.find('entry').[0].at('displayName').text, 'Homer Simpson',
#   'right text';
# is $dom.find('entry').[0].at('id').text, '1286823', 'right text';
# is $dom.find('entry').[0].at('addresses').children('type').[0].text,
#   'home', 'right text';
# is $dom.find('entry').[0].at('addresses formatted').text,
#   "742 Evergreen Terrace\nSpringfield, VT 12345 USA", 'right text';
# is $dom.find('entry').[0].at('addresses formatted').text(0),
#   "742 Evergreen Terrace\nSpringfield, VT 12345 USA", 'right text';
# is $dom.find('entry').[1].at('displayName').text, 'Marge Simpson',
#   'right text';
# is $dom.find('entry').[1].at('id').text, '1286822', 'right text';
# is $dom.find('entry').[1].at('addresses').children('type').[0].text,
#   'home', 'right text';
# is $dom.find('entry').[1].at('addresses formatted').text,
#   '742 Evergreen Terrace Springfield, VT 12345 USA', 'right text';
# is $dom.find('entry').[1].at('addresses formatted').text(0),
#   "742 Evergreen Terrace\nSpringfield, VT 12345 USA", 'right text';
# is $dom.find('entry').[2], Nil, 'no result';
# is $dom.find('entry').size, 2, 'right number of elements';
#
# # Find attribute with hyphen in name and value
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <html>
#   <head><meta http-equiv="content-type" content="text/html"></head>
# </html>
# EOF
# is $dom.find('[http-equiv]').[0]{content}, 'text/html', 'right attribute';
# is $dom.find('[http-equiv]').[1], Nil, 'no result';
# is $dom.find('[http-equiv="content-type"]').[0]{content}, 'text/html',
#   'right attribute';
# is $dom.find('[http-equiv="content-type"]').[1], Nil, 'no result';
# is $dom.find('[http-equiv^="content-"]').[0]{content}, 'text/html',
#   'right attribute';
# is $dom.find('[http-equiv^="content-"]').[1], Nil, 'no result';
# is $dom.find('head > [http-equiv$="-type"]').[0]{content}, 'text/html',
#   'right attribute';
# is $dom.find('head > [http-equiv$="-type"]').[1], Nil, 'no result';
#
# # Find "0" attribute value
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <a accesskey="0">Zero</a>
# <a accesskey="1">O&gTn&gte</a>
# EOF
# is $dom.find('a[accesskey]').[0].text, 'Zero',    'right text';
# is $dom.find('a[accesskey]').[1].text, 'O&gTn>e', 'right text';
# is $dom.find('a[accesskey]').[2], Nil, 'no result';
# is $dom.find('a[accesskey=0]').[0].text, 'Zero', 'right text';
# is $dom.find('a[accesskey=0]').[1], Nil, 'no result';
# is $dom.find('a[accesskey^=0]').[0].text, 'Zero', 'right text';
# is $dom.find('a[accesskey^=0]').[1], Nil, 'no result';
# is $dom.find('a[accesskey$=0]').[0].text, 'Zero', 'right text';
# is $dom.find('a[accesskey$=0]').[1], Nil, 'no result';
# is $dom.find('a[accesskey~=0]').[0].text, 'Zero', 'right text';
# is $dom.find('a[accesskey~=0]').[1], Nil, 'no result';
# is $dom.find('a[accesskey*=0]').[0].text, 'Zero', 'right text';
# is $dom.find('a[accesskey*=0]').[1], Nil, 'no result';
# is $dom.find('a[accesskey=1]').[0].text, 'O&gTn>e', 'right text';
# is $dom.find('a[accesskey=1]').[1], Nil, 'no result';
# is $dom.find('a[accesskey^=1]').[0].text, 'O&gTn>e', 'right text';
# is $dom.find('a[accesskey^=1]').[1], Nil, 'no result';
# is $dom.find('a[accesskey$=1]').[0].text, 'O&gTn>e', 'right text';
# is $dom.find('a[accesskey$=1]').[1], Nil, 'no result';
# is $dom.find('a[accesskey~=1]').[0].text, 'O&gTn>e', 'right text';
# is $dom.find('a[accesskey~=1]').[1], Nil, 'no result';
# is $dom.find('a[accesskey*=1]').[0].text, 'O&gTn>e', 'right text';
# is $dom.find('a[accesskey*=1]').[1], Nil, 'no result';
# is $dom.at('a[accesskey*="."]'), Nil, 'no result';
#
# # Empty attribute value
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <foo bar=>
#   test
# </foo>
# <bar>after</bar>
# EOF
# is $dom.tree.[0], 'root', 'right type';
# is $dom.tree.[1][0], 'tag', 'right type';
# is $dom.tree.[1][1], 'foo', 'right tag';
# is-deeply $dom.tree.[1][2], {bar => ''}, 'right attributes';
# is $dom.tree.[1][4][0], 'text',       'right type';
# is $dom.tree.[1][4][1], "\n  test\n", 'right text';
# is $dom.tree.[3][0], 'tag', 'right type';
# is $dom.tree.[3][1], 'bar', 'right tag';
# is $dom.tree.[3][4][0], 'text',  'right type';
# is $dom.tree.[3][4][1], 'after', 'right text';
# is "$dom", q:to/EOF/, 'right result';
# <foo bar="">
#   test
# </foo>
# <bar>after</bar>
# EOF
#
# # Case-insensitive attribute values
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <p class="foo">A</p>
# <p class="foo bAr">B</p>
# <p class="FOO">C</p>
# EOF
# is $dom.find('.foo').map('text').join(','),            'A,B', 'right result';
# is $dom.find('.FOO').map('text').join(','),            'C',   'right result';
# is $dom.find('[class=foo]').map('text').join(','),     'A',   'right result';
# is $dom.find('[class=foo i]').map('text').join(','),   'A,C', 'right result';
# is $dom.find('[class="foo" i]').map('text').join(','), 'A,C', 'right result';
# is $dom.find('[class="foo bar"]').size, 0, 'no results';
# is $dom.find('[class="foo bar" i]').map('text').join(','), 'B',
#   'right result';
# is $dom.find('[class~=foo]').map('text').join(','), 'A,B', 'right result';
# is $dom.find('[class~=foo i]').map('text').join(','), 'A,B,C',
#   'right result';
# is $dom.find('[class*=f]').map('text').join(','),   'A,B',   'right result';
# is $dom.find('[class*=f i]').map('text').join(','), 'A,B,C', 'right result';
# is $dom.find('[class^=F]').map('text').join(','),   'C',     'right result';
# is $dom.find('[class^=F i]').map('text').join(','), 'A,B,C', 'right result';
# is $dom.find('[class$=O]').map('text').join(','),   'C',     'right result';
# is $dom.find('[class$=O i]').map('text').join(','), 'A,C',   'right result';
#
# # Nested description lists
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <dl>
#   <dt>A</dt>
#   <DD>
#     <dl>
#       <dt>B
#       <dd>C
#     </dl>
#   </dd>
# </dl>
# EOF
# is $dom.find('dl > dd > dl > dt').[0].text, 'B', 'right text';
# is $dom.find('dl > dd > dl > dd').[0].text, 'C', 'right text';
# is $dom.find('dl > dt').[0].text,           'A', 'right text';
#
# # Nested lists
# my $dom = DOM::Tiny.parse(q:to/EOF/);
# <div>
#   <ul>
#     <li>
#       A
#       <ul>
#         <li>B</li>
#         C
#       </ul>
#     </li>
#   </ul>
# </div>
# EOF
# is $dom.find('div > ul > li').[0].text, 'A', 'right text';
# is $dom.find('div > ul > li').[1], Nil, 'no result';
# is $dom.find('div > ul li').[0].text, 'A', 'right text';
# is $dom.find('div > ul li').[1].text, 'B', 'right text';
# is $dom.find('div > ul li').[2], Nil, 'no result';
# is $dom.find('div > ul ul').[0].text, 'C', 'right text';
# is $dom.find('div > ul ul').[1], Nil, 'no result';
#
# # Unusual order
# $dom
#   = DOM::Tiny.parse('<a href="http://example.com" id="foo" class="bar">Ok!</a>');
# is $dom.at('a:not([href$=foo])[href^=h]').text, 'Ok!', 'right text';
# is $dom.at('a:not([href$=example.com])[href^=h]'), Nil, 'no result';
# is $dom.at('a[href^=h]#foo.bar').text, 'Ok!', 'right text';
# is $dom.at('a[href^=h]#foo.baz'), Nil, 'no result';
# is $dom.at('a[href^=h]#foo:not(b)').text, 'Ok!', 'right text';
# is $dom.at('a[href^=h]#foo:not(a)'), Nil, 'no result';
# is $dom.at('[href^=h].bar:not(b)[href$=m]#foo').text, 'Ok!', 'right text';
# is $dom.at('[href^=h].bar:not(b)[href$=m]#bar'), Nil, 'no result';
# is $dom.at(':not(b)#foo#foo').text, 'Ok!', 'right text';
# is $dom.at(':not(b)#foo#bar'), Nil, 'no result';
# is $dom.at(':not([href^=h]#foo#bar)').text, 'Ok!', 'right text';
# is $dom.at(':not([href^=h]#foo#foo)'), Nil, 'no result';
#
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
# is $dom.find('p > svg > circle').size, 2, 'two circles';
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
