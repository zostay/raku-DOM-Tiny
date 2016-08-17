use v6;

use DOM::Tiny::Entities;
use Test;

# html-unescape
is html-unescape('&#x3c;foo&#x3E;bar&lt;baz&gt;&#x0026;&#34;'),
  "<foo>bar<baz>&\"", 'right HTML unescaped result';

# html-unescape (special entities)
is html-unescape('foo &#x2603; &CounterClockwiseContourIntegral; bar &sup1baz'),
  "foo ☃ \x[2233] bar ¹baz", 'right HTML unescaped result';

# html-unescape (multi-character entity)
is html-unescape('&acE;'), "\x[223e]\x[0333]",
  'right HTML unescaped result';

# html-unescape (apos)
is html-unescape('foobar&apos;&lt;baz&gt;&#x26;&#34;'), "foobar'<baz>&\"",
  'right HTML unescaped result';

# html-unescape (nothing to unescape)
is html-unescape('foobar'), 'foobar', 'right HTML unescaped result';

# html-unescape (relaxed)
is html-unescape('&0&Ltf&amp&0oo&nbspba;&ltr'), "&0&Ltf&&0oo\x[00a0]ba;<r",
  'right HTML unescaped result';

# html-unescape (bengal numbers with nothing to unescape)
is html-unescape('&#০৩৯;&#x০৩৯;'), '&#০৩৯;&#x০৩৯;', 'no changes';

# html-unescape (UTF-8)
is html-unescape('foo&lt;baz&gt;&#x26;&#34;&OElig;&Foo;'),
  "foo<baz>&\"\x[152]&Foo;", 'right HTML unescaped result';

# html-escape
is html-escape(qq{la<f>\nbar"baz"'yada\n'&lt;la}),
  "la&lt;f&gt;\nbar&quot;baz&quot;&#39;yada\n&#39;&amp;lt;la",
  'right HTML escaped result';

# html-escape (UTF-8 with nothing to escape)
is html-escape('привет'), 'привет', 'right HTML escaped result';

# html-escape (UTF-8)
is html-escape('привет<foo>'), 'привет&lt;foo&gt;',
  'right HTML escaped result';

done-testing;
