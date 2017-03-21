NAME
====

DOM::Tiny - A lightweight, self-contained DOM parser/manipulator

SYNOPSIS
========

    use DOM::Tiny;

    # Parse
    my $dom = DOM::Tiny.parse('<div><p id="a">Test</p><p id="b">123</p></div>');

    # Find
    say $dom.at('#b').text;
    say $dom.find('p').map(*.text).join("\n");
    say $dom.find('[id]').map(*.attr('id')).join("\n");

    # Iterate
    $dom.find('p[id]').reverse.map({ .<id>.say });

    # Loop
    for $dom.find('p[id]') -> $e {
        say $e<id>, ':', $e.text;
    }

    # Modify
    $dom.find('div p')[*-1].append('<p id="c">456</p>');
    $dom.find(':not(p)').map(*.strip);

    # Render
    say "$dom";

DESCRIPTION
===========

**BEWARE:** This software is still alpha quality. It is a port of a stable, mature module in Perl 5, but this module is neither stable nor mature. It has a large test suite, but this was also ported and many of the tests may not even be applicable to this port. The API itself is fairly mature and will is unlikely to change very much, but the author makes no promises at this point.

DOM::Tiny is a smallish, relaxed pure-Perl HTML/XML DOM parser. It might support some standards as some point, but the implementation is still getting started, so no promises. It is relatively robust owing mostly to the enormous test suite inherited from its progenitor. The HTML/XML parsing is very forgiving and the CSS parser supports a reasonable subset of CSS3 for selecting elements in the DOM tree.

This module started as a port of Mojo::DOM58 from Perl 5, but maintaining compatibility with that library is not a major aim of this project. In fact, features of Perl 6 render certain aspects of Mojo::DOM58 completely redundant. For example, the collection system that provides custom features such as `map`, `each`, `reduce`, etc. are completely unnecessary in Perl 6 as built-in syntax is as simple or simpler to use and safer.

NODES AND ELEMENTS
==================

When we parse an HTML/XML fragment, it gets turned into a tree of nodes.

    <!DOCTYPE html>
    <html>
    <head><title>Hello</title></head>
    <body>World!</body>
    </html>

There are currently the following different kinds of nodes: Root, Text, Tag, Raw, PI, Doctype, Comment, and CDATA. These can also be grouped into the following roles: DocumentNode (anything but Root), Node (all kinds), HasChildren (Root and Tag), and TextNode (includes Text, CDATA, and Raw).

    Root
    |- Doctype (html)
    +- Tag (html)
       |- Tag (head)
       |  +- Tag (title)
       |     +- Text (Hello)
       +- Tag (body)
          +- Text (World!)

While all node types are represented as DOM::Tiny objects, some methods like `attr` and `namespace` only apply to elements.

CASE SENSITIVITY
================

DOM::Tiny defaults to HTML semantics, that means all tags and attribute names are lowercased and selectors need to be lowercase as well.

    # HTML semantics
    my $dom = DOM::Tiny.parse('<P ID="greeting">Hi!</P>');
    say $dom.at('p[id]').text;

If an XML declaration is found at the start of the snippet to parse, the parser will automatically switch into XML mode and everything becomes case-sensitive.

    # XML semantics
    my $dom = DOM::Tiny.parse('<?xml version="1.0"?><P ID="greeting">Hi!</P>');
    say $dom.at('P[ID]').text;

XML detection can also be disabled by setting the `:xml` flag.

    # Force XML semantics
    my $dom = DOM::Tiny.parse('<P ID="greeting">Hi!</P>', :xml);
    say $dom.at('P[ID]').text;

    # Force HTML semantics
    $dom = DOM::Tiny.parse('<P ID="greeting">Hi!</P>', :!xml);
    say $dom.at('p[id]').text;

SELECTORS
=========

DOM::Tiny uses a CSS selector engine found in [DOM::Tiny::CSS](DOM::Tiny::CSS). All CSS selectors that make sense for a standalone parser are supported.

*
-

Any element.

    my $all = $dom.find('*');

E
-

An element of type E.

    my $title = $dom.at('title');

E[foo]
------

An E element with a foo attribute.

    my $links = $dom.find('a[href]');

E[foo="bar"]
------------

An E element whose foo attribute value is exactly equal to bar.

    my $case_sensitive = $dom.find('input[type="hidden"]');
    my $case_sensitive = $dom.find('input[type=hidden]');

E[foo="bar" i]
--------------

An E element whose foo attribute value is exactly equal to any case-permutation of bar.

    my $case_insensitive = $dom.find('input[type="hidden" i]');
    my $case_insensitive = $dom.find('input[type=hidden i]');
    my $case_insensitive = $dom.find('input[class~="foo" i]');

This selector is part of Selectors Level 4, which is still a work in progress.

E[foo~="bar"]
-------------

An E element whose foo attribute value is a list of whitespace-separated values, one of which is exactly equal to bar.

    my $foo = $dom.find('input[class~="foo"]');
    my $foo = $dom.find('input[class~=foo]');

E[foo^="bar"]
-------------

An E element whose foo attribute value begins exactly with the string bar.

    my $begins_with = $dom.find('input[name^="f"]');
    my $begins_with = $dom.find('input[name^=f]');

E[foo$="bar"]
-------------

An E element whose foo attribute value ends exactly with the string bar.

    my $ends_with = $dom.find('input[name$="o"]');
    my $ends_with = $dom.find('input[name$=o]');

E[foo*="bar"]
-------------

An E element whose foo attribute value contains the substring bar.

    my $contains = $dom.find('input[name*="fo"]');
    my $contains = $dom.find('input[name*=fo]');

E:root
------

An E element, root of the document.

    my $root = $dom.at(':root');

E:nth-child(n)
--------------

An E element, the n-th child of its parent.

    my $third = $dom.find('div:nth-child(3)');
    my $odd   = $dom.find('div:nth-child(odd)');
    my $even  = $dom.find('div:nth-child(even)');
    my $top3  = $dom.find('div:nth-child(-n+3)');

E:nth-last-child(n)
-------------------

An E element, the n-th child of its parent, counting from the last one.

    my $third    = $dom.find('div:nth-last-child(3)');
    my $odd      = $dom.find('div:nth-last-child(odd)');
    my $even     = $dom.find('div:nth-last-child(even)');
    my $bottom3  = $dom.find('div:nth-last-child(-n+3)');

E:nth-of-type(n)
----------------

An E element, the n-th sibling of its type.

    my $third = $dom.find('div:nth-of-type(3)');
    my $odd   = $dom.find('div:nth-of-type(odd)');
    my $even  = $dom.find('div:nth-of-type(even)');
    my $top3  = $dom.find('div:nth-of-type(-n+3)');

E:nth-last-of-type(n)
---------------------

An E element, the n-th sibling of its type, counting from the last one.

    my $third    = $dom.find('div:nth-last-of-type(3)');
    my $odd      = $dom.find('div:nth-last-of-type(odd)');
    my $even     = $dom.find('div:nth-last-of-type(even)');
    my $bottom3  = $dom.find('div:nth-last-of-type(-n+3)');

E:first-child
-------------

An E element, first child of its parent.

    my $first = $dom.find('div p:first-child');

E:last-child
------------

An E element, last child of its parent.

    my $last = $dom.find('div p:last-child');

E:first-of-type
---------------

An E element, first sibling of its type.

    my $first = $dom.find('div p:first-of-type');

E:last-of-type
--------------

An E element, last sibling of its type.

    my $last = $dom.find('div p:last-of-type');

E:only-child
------------

An E element, only child of its parent.

    my $lonely = $dom.find('div p:only-child');

E:only-of-type
--------------

An E element, only sibling of its type.

    my $lonely = $dom.find('div p:only-of-type');

E:empty
-------

An E element that has no children (including text nodes).

    my $empty = $dom.find(':empty');

E:checked
---------

A user interface element E which is checked (for instance a radio-button or checkbox).

    my $input = $dom.find(':checked');

E.warning
---------

An E element whose class is "warning".

    my $warning = $dom.find('div.warning');

E#myid
------

An E element with ID equal to "myid".

    my $foo = $dom.at('div#foo');

E:not(s)
--------

An E element that does not match simple selector s.

    my $others = $dom.find('div p:not(:first-child)');

E F
---

An F element descendant of an E element.

    my $headlines = $dom.find('div h1');

E > F
-----

An F element child of an E element.

    my $headlines = $dom.find('html > body > div > h1');

E + F
-----

An F element immediately preceded by an E element.

    my $second = $dom.find('h1 + h2');

E ~ F
-----

An F element preceded by an E element.

    my $second = $dom.find('h1 ~ h2');

E, F, G
-------

Elements of type E, F and G.

    my $headlines = $dom.find('h1, h2, h3');

E[foo=bar][bar=baz]
-------------------

An E element whose attributes match all following attribute selectors.

    my $links = $dom.find('a[foo^=b][foo$=ar]');

OPERATORS AND COERCIONS
=======================

You can use array subscripts and hash subscripts with DOM::Tiny. Using this class as an array or hash, though, is not recommended as several of the standard methods for these do not work as expected.

Array
-----

You may use array subscripts as a shortcut for calling `children`:

    my $third-child = $dom[2];

Hash
----

You may use hash subscripts as a shortcut for calling `attr`:

    my $id = $dom<id>;

Str
---

If you convert the DOM::Tiny object to a string using `Str`, `~`, or putting it in a string, it will render the markup.

    my $html = "$dom";

METHODS
=======

Construction, Parsing, and Rendering
------------------------------------

### method new

    method new(DOM::Tiny:U: Bool :$xml) returns DOM::Tiny:D

Constructs a DOM::Tiny object with an empty DOM tree. Setting the optional `$xml` flag guarantees XML mode. Setting it to a false guarantees HTML mode. If it is unset, DOM::Tiny will select a mode based upon the parsed text, defaulting to HTML.

### method deep-clone

    method deep-clone(DOM::Tiny:D:) returns DOM::Tiny:D

Returns a deep-cloned copy of the current DOM::Tiny object and its children. Any change to the origin will not impact the copy and vice versa.

### method parse

    method parse(DOM::Tiny:U: Str $ml, Bool :$xml) returns DOM::Tiny:D
    method parse(DOM::Tiny:D: Str $ml, Bool :$xml) returns DOM::Tiny:D

Parses the given string, `$ml`, as HTML or XML based upon the `$xml` flag or autodetection if the flag is not given. If called on an existing DOM::Tiny object, the newly parsed tree will replace the previous tree.

### method render

    method render(DOM::Tiny:D:) returns Str:D

This renders the current node and all its content back to a string and returns it. The format of the markup is determined by the current `xml` setting.

### method Str

    method Str(DOM::Tiny:D:) returns Str:D

This is a synonym for `render`.

### method xml

    method xml(DOM::Tiny:D:) is rw returns Bool:D

This is the boolean flag determining how the node was parsed and how it will be rendered.

Finding and Filtering Nodes
---------------------------

### method at

    method at(DOM::Tiny:D: Str:D $selector) returns DOM::Tiny

Given a CSS selector, this will return the first node matching that selector or Nil.

### method find

    method find(DOM::Tiny:D: Str:D $selector)

Returns all nodes matching the given CSS `$selector` within the current node.

### method matches

    method matches(DOM::Tiny:D: Str:D $selector) returns Bool:D

Returns `True` if the current node matches the given `$selector` or `False` otherwise.

Tag Details
-----------

### postcircumfix:<{}>

    method postcircumfix:<{}>(DOM::Tiny:D: Str:D $k) is rw

You may use the `.{}` operator as a shortcut for calling the `attr` method and getting attributes on a tag. You may also use the `:exists` and `:delete` adverbs.

### method hash

    method hash(DOM::Tiny:D:) returns Hash

This is a synonym for `attr`, when it is called with no arguments.

### method all-text

    method all-text(DOM::Tiny:D: Bool :$trim = False) returns Str

Pulls the text from all nodes under the current item in the DOM tree and returns it as a string. This is identical to calling `text` with the `:recurse` flag set to `True`. The `:trim` flag may be set to true, which will cause all trimmable space to be clipped from the returned text (i.e., text not in an RCDATA tag like `title` or `textarea` and not in a `pre` tag).

### method attr

    multi method attr(DOM::Tiny:D:) returns Hash:D
    multi method attr(DOM::Tiny:D: Str:D $name) returns Str
    multi method attr(DOM::Tiny:D: Str:D $name, Str() $value) returns DOM::Tiny:D
    multi method attr(DOM::Tiny:D: Str:D $name, Nil) returns DOM::Tiny:D
    multi method attr(DOM::Tiny:D: *%values) returns DOM::Tiny:D

The `attr` multi-method provides a getter/setter for attributes on the current tag. If the current node is not a tag, this is basically a no-op and will silently do nothing.

With no arguments, the method returns the attributes of the tag as a [Hash](Hash).

With a single string argument, it returns the value of the named attribute or Nil.

With two string arguments, it will set the value of the named attribute and return the current node.

With a string argument and a `Nil`, it will delete the attribute and return the current node.

Given one or more named arguments, the named values will be set to the given values and the current node will be returned.

### method content

    multi method content(DOM::Tiny:D:) returns Str:D
    multi method content(DOM::Tiny:D: DOM::Tiny:D $tree) returns DOM::Tiny:D
    multi method content(DOM::Tiny:D: Str() $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

This multi-method works with the content of the node, something like `innerHTML` in the standard DOM.

Given no arguments, it returns the markup within the element rendered to a string. If the node is empty or has no markup, it will return an empty string.

Given a DOM::Tiny, the tree within that object will replace the content of the current node. If the current node cannot have children, then this is a no-op and will silently do nothing. This returns the current node.

Given a string, the string will be parsed into HTML or XML (based upon the value of the `:xml` named argument, which defaults to the setting for the current node), and the generated node tree will be used to replace the content of the current node. The current node is returned.

### method namespace

    method namespace(DOM::Tiny:D:) returns Str

Returns the namespace URI of the current tag or Str if it has no namespace.

Returns Nil in all other cases (i.e., the current node is not a tag).

### method tag

    multi method tag(DOM::Tiny:D:) returns Str
    multi method tag(DOM::Tiny:D: Str:D $tag) returns DOM::Tiny:D

If the current node is a tag, both versions of this multi-method are no-ops that silently do nothing.

If no arguments are passed, the name of the tag is returned.

If a single string is passed, the name of the tag is changed to the given string and the current node is returned.

### method text

    method text(DOM::Tiny:D: Bool :$trim = False, Bool :$recurse = False) returns Str

This returns the text content of the current node. For a text node, this returns the text of the node itself. For a tag or the root, this will return the text of all of the immediate text node children of the current node concatenated together.

If the argument named `:recurse` is passed, this method will return the text of all descendants rather than just the immediate children. This is the same as calling `all-text`.

If the argument named `:trim` is passed, this method will compress all breaking space into single spaces while concatenating all the text together.

### method type

    method type(DOM::Tiny:D:) returns Node:U

This method returns the type of node that is wrapped within the current DOM::Tiny object. This will be one of the following types:

Root The root node of the tree.

Tag Markup tag nodes within the tree.

Text A regular text node.

CDATA A CDATA text node.

Comment A comment node.

Doctype A DOCTYPE tag element.

PI An XML processing instruction. This is also used to represent the XML declaration even though it is technically not a PI.

Raw A special raw text node, used to represent the text inside of script and style tags.

In addition to these types, you may also want to make use of the following roles, which help group the node types together:

Node All nodes, including the root implement this role.

DocumentNode All nodes that have a parent have this role, i.e., all but the root.

HasChildren Only the nodes that have children have this role, so just Tag and Root.

TextNode All nodes that contain text have this role. This includes Text, CDATA, and Raw.

Each of these classes and roles are exported by `DOM::Tiny` by default. If you prevent these from being exported, you will need to use their full name, which are each prefixed with `DOM::Tiny::HTML::`. For example, `Tag` has the full name `DOM::Tiny::HTML::Tag` and `TextNode` as the full name `DOM::Tiny::HTML::TextNode`.

### method val

    method val(DOM::Tiny:D) returns Str

Returns the value of the tag. Returns `Nil` if the current tag has no notion of value or if the current node is not a tag.

Value is computed as follows, based on the tag name:

  * * **option**: If the option tag has a `value` attribute, that is the option's value. Otherwise, the option's text is used.

  * * **input**: The `value` attribute is used.

  * * **button**: The `value` attribute is used.

  * * **textarea**: The text content of the tag is used as the value.

  * * **select**: The value of the currently selected option is used. If no option is marked as selected, the select tag has no value. If the select tag has the `multiple` attribute set, then this returns all the selected values.

  * * Anything else will return `Nil` for the value.

Tree Navigation
---------------

### method postcircumfix:<[]>

    method postcircumfix:<[]>(DOM::Tiny:D: Int:D $i) is rw

The `.[]` can be used in place of `child-nodes` to retrieve children of the current root or tag from the DOM. The `:exists` and `:delete` adverbs also work.

### method list

    method list(DOM::Tiny:D:) returns List

This is a synonym for `child-nodes`.

### method ancestors

    method ancestors(DOM::Tiny:D: Str $selector?) returns Seq

Returns a sequence of ancestors to the current object as `DOM::Tiny` objects. This will return an empty sequence for the root or any node that no longer has a parent (such as may be the case for a recently removed node).

### method child-nodes

    method child-nodes(DOM::Tiny:D: Bool :$tags-only = False)

If the current node has children (i.e., a tag or root), this method returns all of the children. If the `:tags-only` flag is set, it returns only the children that are tags.

If the current node has no children or is not able to have children, an empty list will be returned.

### method children

    method children(DOM::Tiny:D: Str $selector?)

If the current node has children, this method returns only the tags that are children of the current node. The `$selector` may be set to a CSS selector to filter the children returned. Only those matching the selector will be returned.

If the current node has no children or is not able to have children, an empty list will be returned.

### method descendant-nodes

    method descendant-nodes(DOM::Tiny:D:)

Returns all the descendants of the current node or an empty list if none or the node cannot have descendants. They are returned in depth-first order.

### method following

    method following(DOM::Tiny:D: Str $selector?)

Returns all sibling tags of the current node that come after the current node.

### method following-nodes

    method following-nodes(DOM::Tiny:D:)

Returns all sibling nodes of the current node that come after the current node.

### method next

    method next(DOM::Tiny:D:) returns DOM::Tiny

Returns the next sibling tag of the current node. If there is no such sibling, it returns `Nil`.

### method next-node

    method next-node(DOM::Tiny:D:) returns DOM::Tiny

Returns the next sibling node of the current node. If there is no such sibling, it returns `Nil`.

### method parent

    method parent(DOM::Tiny:D:) returns DOM::Tiny

Returns the parent of the current node. If the current node is the root, this method returns `Nil` instead.

### method preceding

    method preceding(DOM::Tiny:D: Str $selector?)

Retursn all siblings of the current node that are tags that come before the current node. A `$selector` may be given to filter the returned tags.

### method preceding-nodes

    method preceding-nodes(DOM::Tiny:D:)

Returns all siblings nodes of the current node that precede the current node.

### method previous

    method previous(DOM::Tiny:D:) returns DOM::Tiny

Returns the previous sibling tag of the current node. If there is no such sibling, it returns `Nil`.

### method previous-node

    method previous-node(DOM::Tiny:D:) returns DOM::Tiny

Returns the previous sibling node of the current node. If there is no such sibling, it returns `Nil`.

### method root

    method root(DOM::Tiny:D:) returns DOM::Tiny:D

Returns the root node of the tree.

Tree Modification
-----------------

### method append

    method append(DOM::Tiny:D: Str() $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

Appends the given markup content immediately after the current node. The `:xml` flag may be set to determine whether the given markup should be parsed as XML or HTML (with the default being whatever the current document is being treated as).

If the current node is the root (i.e., `$dom.type ~~ Root`), this operation is a no-op. It will silently do nothing.

Returns the current node.

### method append-content

    method append-content(DOM::Tiny:D: Str() $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

If this is the root or a tag (i.e., `$dom.type ~~ Root|Tag`), the given markup will be parsed and appended to the end of the root's or tag's children. If this is a text node (i.e., `$dom.type ~~ TextNode`), then the markup will be appended to the text node parent's children. Otherwise this is a no-op and will silently do nothing.

The `:xml` flag may be used to specify the format for the markup being parsed, defaulting to the setting for the current document.

Returns the node whose children have been modified.

### method prepend

    method prepend(DOM::Tiny:D: Str() $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

Appends the given markup content immediately before the current node. The `:xml` flag may be set to tell the parser to parse in XML mode or not (with the default being whatever is set for the current node).

If the current node is the root, this operation is a no-op and will silently do nothing.

This method will return the current node.

### method prepend-content

    method prepend-content(DOM::Tiny:D: Str() $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

Appends the given markup content at the beginning of the current node's children, if it is the root or a tag. (This is a no-op that silently does nothing unless the current node is the root or a tag.) The `:xml` flag sets whether to parse the `$ml` as XML or not, with the default being the xml mode flag set on the current node.

This method returns the current node.

### method remove

    method remove(DOM::Tiny:D:) returns DOM::Tiny:D

Removes the current node from the tree and returns the parent node. If this node is the root, then the tree is emptied and the current node (i.e., the root) is returned.

### method replace

    method replace(DOM::Tiny:D: DOM::Tiny:D $tree) returns DOM::Tiny:D
    method replace(DOM::Tiny:D: Str() $ml) returns DOM::Tiny:D

The current node is replaced with the tree or markup given.

If the current node is the root, the current node is returned. Otherwise, the original parent of this node, which has been replaced with the new tree, is returned.

### method strip

    method strip(DOM::Tiny:D:) returns DOM::Tiny:D

If the current node is a tag, the tag is removed from the tree and its content moved up into the current node's original parent. This will then return the original node's parent.

If the current node is anything else, this is a no-op that will silently do nothing and return the current node.

### method wrap

    method wrap(DOM::Tiny:D: Str:D $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

The given markup in `$ml` is parsed according to the format given by the `:xml` flag (defaulting to whatever the `xml` setting is for the current node). The current node is put within the innermost tag of the given markup. The current node is returned.

This is a no-op and will silently do nothing if the current node is the root.

### method wrap-content

    method wrap-content(DOM::Tiny:D: Str:D $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

This is a no-op and will silently do nothing unless the current node is the root or a tag.

The given markup in `$ml` is parsed. The parsing proceeds as XML if the `:xml` flag is set or HTML otherwise (with the default being whatever the `xml` flag is set to on the current node). The content of the current node is then placed within the innermost tag of the parsed markup and that parsed markup replaces the content of the current node.

AUTHOR AND COPYRIGHT
====================

Copyright 2008-2016 Sebastian Riedel and others.

Copyright 2016 Andrew Sterling Hanenkamp for the port to Perl 6.

This is free software, licensed under:

The Artistic License 2.0 (GPL Compatible)
