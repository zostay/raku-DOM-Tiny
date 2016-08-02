#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Already decoded Unicode snowman and quotes in selector
my $dom = DOM::Tiny.parse('<div id="snow&apos;m&quot;an">â˜ƒ</div>');
is $dom.at('[id="snow\'m\"an"]').text,      'â˜ƒ', 'right text';
is $dom.at('[id="snow\'m\22 an"]').text,    'â˜ƒ', 'right text';
is $dom.at('[id="snow\'m\000022an"]').text, 'â˜ƒ', 'right text';
is $dom.at('[id="snow\'m\22an"]'),      Nil, 'no result';
is $dom.at('[id="snow\'m\21 an"]'),     Nil, 'no result';
is $dom.at('[id="snow\'m\000021an"]'),  Nil, 'no result';
is $dom.at('[id="snow\'m\000021 an"]'), Nil, 'no result';
is $dom.at("[id='snow\\'m\"an']").text,  'â˜ƒ', 'right text';
is $dom.at("[id='snow\\27m\"an']").text, 'â˜ƒ', 'right text';

done-testing;
