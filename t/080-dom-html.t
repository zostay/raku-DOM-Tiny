#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Ensure HTML semantics
ok !DOM::Tiny.parse('<?xml version="1.0"?>', :!xml).xml,
  'XML mode not detected';
my $dom = DOM::Tiny.parse('<?xml version="1.0"?><br><div>Test</div>', :!xml);
is $dom.at('div:root').text, 'Test', 'right text';

done-testing;
