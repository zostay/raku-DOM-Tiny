#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Pseudo-classes
my $dom = DOM::Tiny.parse(q:to/EOF/);
<form action="/foo">
    <input type="text" name="user" value="test" />
    <input type="checkbox" checked="checked" name="groovy">
    <select name="a">
        <option value="b">b</option>
        <optgroup label="c">
            <option value="d">d</option>
            <option selected="selected" value="e">E</option>
            <option value="f">f</option>
        </optgroup>
        <option value="g">g</option>
        <option selected value="h">H</option>
    </select>
    <input type="submit" value="Ok!" />
    <input type="checkbox" checked name="I">
    <p id="content">test 123</p>
    <p id="no_content"><? test ?><!-- 123 --></p>
</form>
EOF
is $dom.find(':root').[0].tag,     'form', 'right tag';
is $dom.find('*:root').[0].tag,    'form', 'right tag';
is $dom.find('form:root').[0].tag, 'form', 'right tag';
is $dom.find(':root').[1], Nil, 'no result';
is $dom.find(':checked').[0].attr<name>,        'groovy', 'right name';
is $dom.find('option:checked').[0].attr<value>, 'e',      'right value';
is $dom.find(':checked').[1].text,  'E', 'right text';
is $dom.find('*:checked').[1].text, 'E', 'right text';
is $dom.find(':checked').[2].text,  'H', 'right name';
is $dom.find(':checked').[3].attr<name>, 'I', 'right name';
is $dom.find(':checked').[4], Nil, 'no result';
is $dom.find('option[selected]').[0].attr<value>, 'e', 'right value';
is $dom.find('option[selected]').[1].text, 'H', 'right text';
is $dom.find('option[selected]').[2], Nil, 'no result';
is $dom.find(':checked[value="e"]').[0].text,       'E', 'right text';
is $dom.find('*:checked[value="e"]').[0].text,      'E', 'right text';
is $dom.find('option:checked[value="e"]').[0].text, 'E', 'right text';
is $dom.at('optgroup option:checked[value="e"]').text, 'E', 'right text';
is $dom.at('select option:checked[value="e"]').text,   'E', 'right text';
is $dom.at('select :checked[value="e"]').text,         'E', 'right text';
is $dom.at('optgroup > :checked[value="e"]').text,     'E', 'right text';
is $dom.at('select *:checked[value="e"]').text,        'E', 'right text';
is $dom.at('optgroup > *:checked[value="e"]').text,    'E', 'right text';
is $dom.find(':checked[value="e"]').[1], Nil, 'no result';
is $dom.find(':empty').[0].attr<name>,      'user', 'right name';
is $dom.find('input:empty').[0].attr<name>, 'user', 'right name';
is $dom.at(':empty[type^="ch"]').attr<name>, 'groovy',  'right name';
is $dom.at('p').attr<id>,                    'content', 'right attribute';
is $dom.at('p:empty').attr<id>, 'no_content', 'right attribute';

done-testing;
