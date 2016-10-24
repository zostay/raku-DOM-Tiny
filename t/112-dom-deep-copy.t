#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

plan 2;

{
    my $dom1 = DOM::Tiny.parse("<body><p>Foo<b>Bar</b>Baz</p>Blah</body>");
    my $dom2 = $dom1.deep-clone;

    $dom1.at('p')».content('nix');
    isnt ~$dom1, ~$dom2, 'dom1 and dom2 differ';
}

{
    my $dom1 = DOM::Tiny.parse("<body><p>Foo<b>Bar</b>Baz</p>Blah</body>");
    my $dom2 = $dom1.deep-clone;

    $dom2.at('p')».content('nix');
    isnt ~$dom1, ~$dom2, 'dom1 and dom2 differ';
}
