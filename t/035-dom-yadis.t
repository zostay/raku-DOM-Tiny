#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Yadis
my $dom = DOM::Tiny.parse(q:to/EOF/);
<?xml version="1.0" encoding="UTF-8"?>
<XRDS xmlns="xri://$xrds">
  <XRD xmlns="xri://$xrd*($v*2.0)">
    <Service>
      <Type>http://o.r.g/sso/2.0</Type>
    </Service>
    <Service>
      <Type>http://o.r.g/sso/1.0</Type>
    </Service>
  </XRD>
</XRDS>
EOF
ok $dom.xml, 'XML mode detected';
is $dom.at('XRDS').namespace, 'xri://$xrds',         'right namespace';
is $dom.at('XRD').namespace,  'xri://$xrd*($v*2.0)', 'right namespace';
my $s = $dom.find('XRDS XRD Service').cache;
is $s.[0].at('Type').text, 'http://o.r.g/sso/2.0', 'right text';
is $s.[0].namespace, 'xri://$xrd*($v*2.0)', 'right namespace';
is $s.[1].at('Type').text, 'http://o.r.g/sso/1.0', 'right text';
is $s.[1].namespace, 'xri://$xrd*($v*2.0)', 'right namespace';
is $s.[2], Nil, 'no result';
is $s.elems, 2, 'right number of elements';

done-testing;
