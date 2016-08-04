#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Yadis (roundtrip with namespace)
my $yadis = q:to/EOF/;
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS xmlns="xri://$xrd*($v*2.0)" xmlns:xrds="xri://$xrds">
  <XRD>
    <Service>
      <Type>http://o.r.g/sso/3.0</Type>
    </Service>
    <xrds:Service>
      <Type>http://o.r.g/sso/4.0</Type>
    </xrds:Service>
  </XRD>
  <XRD>
    <Service>
      <Type test="23">http://o.r.g/sso/2.0</Type>
    </Service>
    <Service>
      <Type Test="23" test="24">http://o.r.g/sso/1.0</Type>
    </Service>
  </XRD>
</xrds:XRDS>
EOF
my $dom = DOM::Tiny.parse($yadis);
ok $dom.xml, 'XML mode detected';
is $dom.at('XRDS').namespace, 'xri://$xrds',         'right namespace';
is $dom.at('XRD').namespace,  'xri://$xrd*($v*2.0)', 'right namespace';
my $s = $dom.find('XRDS XRD Service').cache;
is $s.[0].at('Type').text, 'http://o.r.g/sso/3.0', 'right text';
is $s.[0].namespace, 'xri://$xrd*($v*2.0)', 'right namespace';
is $s.[1].at('Type').text, 'http://o.r.g/sso/4.0', 'right text';
is $s.[1].namespace, 'xri://$xrds', 'right namespace';
is $s.[2].at('Type').text, 'http://o.r.g/sso/2.0', 'right text';
is $s.[2].namespace, 'xri://$xrd*($v*2.0)', 'right namespace';
is $s.[3].at('Type').text, 'http://o.r.g/sso/1.0', 'right text';
is $s.[3].namespace, 'xri://$xrd*($v*2.0)', 'right namespace';
is $s.[4], Nil, 'no result';
is $s.elems, 4, 'right number of elements';
is $dom.at('[Test="23"]').text, 'http://o.r.g/sso/1.0', 'right text';
is $dom.at('[test="23"]').text, 'http://o.r.g/sso/2.0', 'right text';
is $dom.find('xrds\:Service > Type').[0].text, 'http://o.r.g/sso/4.0',
  'right text';
is $dom.find('xrds\:Service > Type').[1], Nil, 'no result';
is $dom.find('xrds\3AService > Type').[0].text, 'http://o.r.g/sso/4.0',
  'right text';
is $dom.find('xrds\3AService > Type').[1], Nil, 'no result';
is $dom.find('xrds\3A Service > Type').[0].text, 'http://o.r.g/sso/4.0',
  'right text';
is $dom.find('xrds\3A Service > Type').[1], Nil, 'no result';
is $dom.find('xrds\00003AService > Type').[0].text, 'http://o.r.g/sso/4.0',
  'right text';
is $dom.find('xrds\00003AService > Type').[1], Nil, 'no result';
is $dom.find('xrds\00003A Service > Type').[0].text, 'http://o.r.g/sso/4.0',
  'right text';
is $dom.find('xrds\00003A Service > Type').[1], Nil, 'no result';
is "$dom", $yadis, 'successful roundtrip';

done-testing;
