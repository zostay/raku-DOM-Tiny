#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Inline DTD
my $dom = DOM::Tiny.parse(q:to/EOF/);
<?xml version="1.0"?>
<!-- This is a Test! -->
<!DOCTYPE root [
  <!ELEMENT root (#PCDATA)>
  <!ATTLIST root att CDATA #REQUIRED>
]>
<root att="test">
  <![CDATA[<hello>world</hello>]]>
</root>
EOF
ok $dom.xml, 'XML mode detected';
is $dom.at('root').attr('att'), 'test', 'right attribute';
is $dom.tree.children[4].doctype, 'root [
  <!ELEMENT root (#PCDATA)>
  <!ATTLIST root att CDATA #REQUIRED>
]', 'right doctype';
is $dom.at('root').text(:trim), '<hello>world</hello>', 'right text';
$dom = DOM::Tiny.parse(q:to/EOF/);
<!doctype book
SYSTEM "usr.dtd"
[
  <!ENTITY test "yeah">
]>
<foo />
EOF
is $dom.tree.children[0].doctype, 'book
SYSTEM "usr.dtd"
[
  <!ENTITY test "yeah">
]', 'right doctype';
ok !$dom.xml, 'XML mode not detected';
is $dom.at('foo'), '<foo></foo>', 'right element';
$dom = DOM::Tiny.parse(q:to/EOF/);
<?xml version="1.0" encoding = 'utf-8'?>
<!DOCTYPE foo [
  <!ELEMENT foo ANY>
  <!ATTLIST foo xml:lang CDATA #IMPLIED>
  <!ENTITY % e SYSTEM "myentities.ent">
  %myentities;
]  >
<foo xml:lang="de">Check!</fOo>
EOF
ok $dom.xml, 'XML mode detected';
is $dom.tree.children[2].doctype, 'foo [
  <!ELEMENT foo ANY>
  <!ATTLIST foo xml:lang CDATA #IMPLIED>
  <!ENTITY % e SYSTEM "myentities.ent">
  %myentities;
]  ', 'right doctype';
is $dom.at('foo').attr.{'xml:lang'}, 'de', 'right attribute';
is $dom.at('foo').text(:trim), 'Check!', 'right text';
$dom = DOM::Tiny.parse(q:to/EOF/);
<!DOCTYPE TESTSUITE PUBLIC "my.dtd" 'mhhh' [
  <!ELEMENT foo ANY>
  <!ATTLIST foo bar ENTITY 'true'>
  <!ENTITY system_entities SYSTEM 'systems.xml'>
  <!ENTITY leertaste '&#32;'>
  <!-- This is a comment -->
  <!NOTATION hmmm SYSTEM "hmmm">
]   >
<?check for-nothing?>
<foo bar='false'>&leertaste;!!!</foo>
EOF
is $dom.tree.children[0].doctype, 'TESTSUITE PUBLIC "my.dtd" \'mhhh\' [
  <!ELEMENT foo ANY>
  <!ATTLIST foo bar ENTITY \'true\'>
  <!ENTITY system_entities SYSTEM \'systems.xml\'>
  <!ENTITY leertaste \'&#32;\'>
  <!-- This is a comment -->
  <!NOTATION hmmm SYSTEM "hmmm">
]   ', 'right doctype';
is $dom.at('foo').attr('bar'), 'false', 'right attribute';

done-testing;
