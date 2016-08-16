#!/usr/bin/env perl6
use v6;

use Test;
use DOM::Tiny;

# Form values
my $dom = DOM::Tiny.parse(q:to/EOF/);
<form action="/foo">
  <p>Test</p>
  <input type="text" name="a" value="A" />
  <input type="checkbox" name="q">
  <input type="checkbox" checked name="b" value="B">
  <input type="radio" name="r">
  <input type="radio" checked name="c" value="C">
  <input name="s">
  <input type="checkbox" name="t" value="">
  <input type=text name="u">
  <select multiple name="f">
    <option value="F">G</option>
    <optgroup>
      <option>H</option>
      <option selected>I</option>
    </optgroup>
    <option value="J" selected>K</option>
  </select>
  <select name="n"><option>N</option></select>
  <select multiple name="q"><option>Q</option></select>
  <select name="d">
    <option selected>R</option>
    <option selected>D</option>
  </select>
  <textarea name="m">M</textarea>
  <button name="o" value="O">No!</button>
  <input type="submit" name="p" value="P" />
</form>
EOF
is $dom.at('p').val,                         Nil, 'no value';
is $dom.at('input').val,                     'A',   'right value';
is $dom.at('input:checked').val,             'B',   'right value';
is $dom.at('input:checked[type=radio]').val, 'C',   'right value';
is-deeply $dom.at('select').val, ('I', 'J'), 'right values';
is $dom.at('select option').val,                          'F', 'right value';
is $dom.at('select optgroup option:not([selected])').val, 'H', 'right value';
is $dom.find('select').[1].at('option').val, 'N', 'right value';
is $dom.find('select').[1].val,        Nil, 'no value';
is-deeply $dom.find('select').[2].val, (), 'no value';
is $dom.find('select').[2].at('option').val, 'Q', 'right value';
is-deeply $dom.find('select').[*-1].val, 'D', 'right value';
is-deeply $dom.find('select').[*-1].at('option').val, 'R', 'right value';
is $dom.at('textarea').val, 'M', 'right value';
is $dom.at('button').val,   'O', 'right value';
is $dom.find('form input').[*-1].val, 'P', 'right value';
is $dom.at('input[name=q]').val, 'on',  'right value';
is $dom.at('input[name=r]').val, 'on',  'right value';
is $dom.at('input[name=s]').val, Str, 'no value';
is $dom.at('input[name=t]').val, '',    'right value';
is $dom.at('input[name=u]').val, Str, 'no value';

done-testing;
