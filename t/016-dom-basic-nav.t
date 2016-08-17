#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

my $dom = DOM::Tiny.new.parse(q:to/EOF/);
<!doctype foo>
<foo bar="ba&lt;z">
  test
  <simple class="working">easy</simple>
  <test foo="bar" id="test" />
  <!-- lala -->
  works well
  <![CDATA[ yada yada]]>
  <?boom lalalala ?>
  <a little bit broken>
  < very broken
  <br />
  more text
</foo>
EOF
ok !$dom.xml, 'XML mode not detected';
is $dom.tag, Nil, 'no tag';
is $dom.attr('foo'), Str, 'no attribute';
is $dom.attr(foo => 'bar').attr('foo'), Str, 'no attribute';
is $dom.tree.children[0].WHAT, Doctype, 'right type';
is $dom.tree.children[0].doctype, 'foo', 'right doctype';
is "$dom", q:to/EOF/, 'right result';
<!DOCTYPE foo>
<foo bar="ba&lt;z">
  test
  <simple class="working">easy</simple>
  <test foo="bar" id="test"></test>
  <!-- lala -->
  works well
  <![CDATA[ yada yada]]>
  <?boom lalalala ?>
  <a bit broken little>
  &lt; very broken
  <br>
  more text
</a></foo>
EOF
my $simple = $dom.at('foo simple.working[class^="wor"]');
is $simple.parent.all-text(:trim),
  'test easy works well yada yada < very broken more text', 'right text';
is $simple.tag, 'simple', 'right tag';
is $simple.attr('class'), 'working', 'right class attribute';
is $simple.text, 'easy', 'right text';
is $simple.parent.tag, 'foo', 'right parent tag';
is $simple.parent.attr<bar>, 'ba<z', 'right parent attribute';
is $simple.parent.children[1].tag, 'test', 'right sibling';
is $simple.Str, '<simple class="working">easy</simple>',
  'stringified right';
$simple.parent.attr(bar => 'baz').attr(this => 'works', too => 'yea');
is $simple.parent.attr('bar'),  'baz',   'right parent attribute';
is $simple.parent.attr('this'), 'works', 'right parent attribute';
is $simple.parent.attr('too'),  'yea',   'right parent attribute';
is $dom.at('test#test').tag,              'test',   'right tag';
is $dom.at('[class$="ing"]').tag,         'simple', 'right tag';
is $dom.at('[class="working"]').tag,      'simple', 'right tag';
is $dom.at('[class$=ing]').tag,           'simple', 'right tag';
is $dom.at('[class=working][class]').tag, 'simple', 'right tag';
is $dom.at('foo > simple').next.tag, 'test', 'right tag';
is $dom.at('foo > simple').next.next.tag, 'a', 'right tag';
is $dom.at('foo > test').previous.tag, 'simple', 'right tag';
is $dom.next,     Nil, 'no siblings';
is $dom.previous, Nil, 'no siblings';
is $dom.at('foo > a').next,          Nil, 'no next sibling';
is $dom.at('foo > simple').previous, Nil, 'no previous sibling';
is-deeply $dom.at('simple').ancestors».tag, ('foo',),
  'right results';
ok !$dom.at('simple').ancestors.first.xml, 'XML mode not active';

done-testing;
