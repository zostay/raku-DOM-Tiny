#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# PoCo example with whitespace sensitive text
my $dom = DOM::Tiny.parse(q:to/EOF/);
<?xml version="1.0" encoding="UTF-8"?>
<response>
  <entry>
    <id>1286823</id>
    <displayName>Homer Simpson</displayName>
    <addresses>
      <type>home</type>
      <formatted><![CDATA[742 Evergreen Terrace
Springfield, VT 12345 USA]]></formatted>
    </addresses>
  </entry>
  <entry>
    <id>1286822</id>
    <displayName>Marge Simpson</displayName>
    <addresses>
      <type>home</type>
      <formatted>742 Evergreen Terrace
Springfield, VT 12345 USA</formatted>
    </addresses>
  </entry>
</response>
EOF
is $dom.find('entry').[0].at('displayName').text, 'Homer Simpson',
  'right text';
is $dom.find('entry').[0].at('id').text, '1286823', 'right text';
is $dom.find('entry').[0].at('addresses').children('type').[0].text,
  'home', 'right text';
is $dom.find('entry').[0].at('addresses formatted').text,
  "742 Evergreen Terrace\nSpringfield, VT 12345 USA", 'right text';
is $dom.find('entry').[0].at('addresses formatted').text(:!trim),
  "742 Evergreen Terrace\nSpringfield, VT 12345 USA", 'right text';
is $dom.find('entry').[1].at('displayName').text, 'Marge Simpson',
  'right text';
is $dom.find('entry').[1].at('id').text, '1286822', 'right text';
is $dom.find('entry').[1].at('addresses').children('type').[0].text,
  'home', 'right text';
is $dom.find('entry').[1].at('addresses formatted').text(:trim),
  '742 Evergreen Terrace Springfield, VT 12345 USA', 'right text';
is $dom.find('entry').[1].at('addresses formatted').text(:!trim),
  "742 Evergreen Terrace\nSpringfield, VT 12345 USA", 'right text';
is $dom.find('entry').[2], Nil, 'no result';
is $dom.find('entry').elems, 2, 'right number of elements';

done-testing;
