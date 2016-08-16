#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# RSS
my $dom = DOM::Tiny.parse(q:to/EOF/);
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
  <channel>
    <title>Test Blog</title>
    <link>http://blog.example.com</link>
    <description>lalala</description>
    <generator>DOM::Tiny</generator>
    <item>
      <pubDate>Mon, 12 Jul 2010 20:42:00</pubDate>
      <title>Works!</title>
      <link>http://blog.example.com/test</link>
      <guid>http://blog.example.com/test</guid>
      <description>
        <![CDATA[<p>trololololo>]]>
      </description>
      <my:extension foo:id="works">
        <![CDATA[
          [awesome]]
        ]]>
      </my:extension>
    </item>
  </channel>
</rss>
EOF
ok $dom.xml, 'XML mode detected';
is $dom.find('rss').[0].attr('version'), '2.0', 'right version';
is-deeply $dom.at('title').ancestors».tag, <channel rss>,
  'right results';
is $dom.at('extension').attr('foo:id'), 'works', 'right id';
like $dom.at('#works').text,       rx/'[awesome]]'/, 'right text';
like $dom.at('[id="works"]').text, rx/'[awesome]]'/, 'right text';
is $dom.find('description')[1].text(:trim), '<p>trololololo>', 'right text';
is $dom.at('pubDate').text,        'Mon, 12 Jul 2010 20:42:00', 'right text';
like $dom.at('[id*="ork"]').text,  rx/'[awesome]]'/,           'right text';
like $dom.at('[id*="orks"]').text, rx/'[awesome]]'/,           'right text';
like $dom.at('[id*="work"]').text, rx/'[awesome]]'/,           'right text';
like $dom.at('[id*="or"]').text,   rx/'[awesome]]'/,           'right text';
ok $dom.at('rss').xml,             'XML mode active';
ok $dom.at('extension').parent.xml, 'XML mode active';
ok $dom.at('extension').root.xml,   'XML mode active';
ok $dom.children('rss').first.xml,  'XML mode active';
ok $dom.at('title').ancestors.first.xml, 'XML mode active';

done-testing;
