#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Modifying an XML document
my $dom = DOM::Tiny.parse(q:to/EOF/);
<?xml version='1.0' encoding='UTF-8'?>
<XMLTest />
EOF
ok $dom.xml, 'XML mode detected';
$dom.at('XMLTest').content('<Element />');
my $element = $dom.at('Element');
is $element.tag, 'Element', 'right tag';
ok $element.xml, 'XML mode active';
$element = $dom.at('XMLTest').children.[0];
is $element.tag, 'Element', 'right child';
is $element.parent.tag, 'XMLTest', 'right parent';
ok $element.root.xml, 'XML mode active';
$dom.replace('<XMLTest2 /><XMLTest3 just="works" />');
ok $dom.xml, 'XML mode active';
$dom.at('XMLTest2')<foo> = Nil;
is $dom, '<XMLTest2 foo="foo" /><XMLTest3 just="works" />', 'right result';

done-testing;
