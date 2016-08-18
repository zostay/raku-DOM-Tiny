unit class DOM::Tiny;
use v6;

use DOM::Tiny::CSS;
use DOM::Tiny::HTML;

my package EXPORT::DEFAULT {
    for < Root Text Tag Raw PI Doctype Comment CDATA DocumentNode Node HasChildren TextNode > -> $type {
        OUR::{ "$type" } := DOM::Tiny::HTML::{ $type };
    }
}

=begin pod

=NAME DOM::Tiny - A lightweight, self-contained DOM parser/manipulator

=begin SYNOPSIS

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

=end SYNOPSIS

=begin DESCRIPTION

DOM::Tiny is a smallish, relaxed pure-Perl HTML/XML DOM parser. It might support
some standards as some point, but the implementation is still getting started,
so no promises. It is relatively robust owing mostly to the enormous test suite
inherited from its progenitor. The HTML/XML parsing is very forgiving and the
CSS parser supports a reasonable subset of CSS3 for selecting elements in the
DOM tree.

This module started as a port of Mojo::DOM58 from Perl 5, but maintaining
compatibility with that library is not a major aim of this project. In fact,
features of Perl 6 render certain aspects of Mojo::DOM58 completely redundant.
For example, the collection system that provides custom features such as C<map>,
C<each>, C<reduce>, etc. are completely unnecessary in Perl 6 as built-in syntax
is as simple or simpler to use and safer.

=end DESCRIPTION

=head1 NODES AND ELEMENTS

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

While all node types are represented as DOM::Tiny objects, some methods like C<attr> and C<namespace> only apply to elements.

=head1 CASE SENSITIVITY

DOM::Tiny defaults to HTML semantics, that means all tags and attribute names are lowercased and selectors need to be lowercase as well.

    # HTML semantics
    my $dom = DOM::Tiny.parse('<P ID="greeting">Hi!</P>');
    say $dom.at('p[id]').text;

If an XML declaration is found at the start of the snippet to parse, the parser will automatically switch into XML mode and everything becomes case-sensitive.

    # XML semantics
    my $dom = DOM::Tiny.parse('<?xml version="1.0"?><P ID="greeting">Hi!</P>');
    say $dom.at('P[ID]').text;

XML detection can also be disabled by setting the C<:xml> flag.

    # Force XML semantics
    my $dom = DOM::Tiny.parse('<P ID="greeting">Hi!</P>', :xml);
    say $dom.at('P[ID]').text;

    # Force HTML semantics
    $dom = DOM::Tiny.parse('<P ID="greeting">Hi!</P>', :!xml);
    say $dom.at('p[id]').text;

=head1 SELECTORS

DOM::Tiny uses a CSS selector engine found in L<DOM::Tiny::CSS>. All CSS selectors that make sense for a standalone parser are supported.

=head2 *

Any element.

    my $all = $dom.find('*');

=head2 E

An element of type E.

    my $title = $dom.at('title');

=head2 E[foo]

An E element with a foo attribute.

    my $links = $dom.find('a[href]');

=head2 E[foo="bar"]

An E element whose foo attribute value is exactly equal to bar.

    my $case_sensitive = $dom.find('input[type="hidden"]');
    my $case_sensitive = $dom.find('input[type=hidden]');

=head2 E[foo="bar" i]

An E element whose foo attribute value is exactly equal to any case-permutation of bar.

    my $case_insensitive = $dom.find('input[type="hidden" i]');
    my $case_insensitive = $dom.find('input[type=hidden i]');
    my $case_insensitive = $dom.find('input[class~="foo" i]');

This selector is part of Selectors Level 4, which is still a work in progress.

=head2 E[foo~="bar"]

An E element whose foo attribute value is a list of whitespace-separated values, one of which is exactly equal to bar.

    my $foo = $dom.find('input[class~="foo"]');
    my $foo = $dom.find('input[class~=foo]');

=head2 E[foo^="bar"]

An E element whose foo attribute value begins exactly with the string bar.

    my $begins_with = $dom.find('input[name^="f"]');
    my $begins_with = $dom.find('input[name^=f]');

=head2 E[foo$="bar"]

An E element whose foo attribute value ends exactly with the string bar.

    my $ends_with = $dom.find('input[name$="o"]');
    my $ends_with = $dom.find('input[name$=o]');

=head2 E[foo*="bar"]

An E element whose foo attribute value contains the substring bar.

    my $contains = $dom.find('input[name*="fo"]');
    my $contains = $dom.find('input[name*=fo]');

=head2 E:root

An E element, root of the document.

    my $root = $dom.at(':root');

=head2 E:nth-child(n)

An E element, the n-th child of its parent.

    my $third = $dom.find('div:nth-child(3)');
    my $odd   = $dom.find('div:nth-child(odd)');
    my $even  = $dom.find('div:nth-child(even)');
    my $top3  = $dom.find('div:nth-child(-n+3)');

=head2 E:nth-last-child(n)

An E element, the n-th child of its parent, counting from the last one.

    my $third    = $dom.find('div:nth-last-child(3)');
    my $odd      = $dom.find('div:nth-last-child(odd)');
    my $even     = $dom.find('div:nth-last-child(even)');
    my $bottom3  = $dom.find('div:nth-last-child(-n+3)');

=head2 E:nth-of-type(n)

An E element, the n-th sibling of its type.

    my $third = $dom.find('div:nth-of-type(3)');
    my $odd   = $dom.find('div:nth-of-type(odd)');
    my $even  = $dom.find('div:nth-of-type(even)');
    my $top3  = $dom.find('div:nth-of-type(-n+3)');

=head2 E:nth-last-of-type(n)

An E element, the n-th sibling of its type, counting from the last one.

    my $third    = $dom.find('div:nth-last-of-type(3)');
    my $odd      = $dom.find('div:nth-last-of-type(odd)');
    my $even     = $dom.find('div:nth-last-of-type(even)');
    my $bottom3  = $dom.find('div:nth-last-of-type(-n+3)');

=head2 E:first-child

An E element, first child of its parent.

    my $first = $dom.find('div p:first-child');

=head2 E:last-child

An E element, last child of its parent.

    my $last = $dom.find('div p:last-child');

=head2 E:first-of-type

An E element, first sibling of its type.

    my $first = $dom.find('div p:first-of-type');

=head2 E:last-of-type

An E element, last sibling of its type.

    my $last = $dom.find('div p:last-of-type');

=head2 E:only-child

An E element, only child of its parent.

    my $lonely = $dom.find('div p:only-child');

=head2 E:only-of-type

An E element, only sibling of its type.

    my $lonely = $dom.find('div p:only-of-type');

=head2 E:empty

An E element that has no children (including text nodes).

    my $empty = $dom.find(':empty');

=head2 E:checked

A user interface element E which is checked (for instance a radio-button or checkbox).

    my $input = $dom.find(':checked');

=head2 E.warning

An E element whose class is "warning".

    my $warning = $dom.find('div.warning');

=head2 E#myid

An E element with ID equal to "myid".

    my $foo = $dom.at('div#foo');

=head2 E:not(s)

An E element that does not match simple selector s.

    my $others = $dom.find('div p:not(:first-child)');

=head2 E F

An F element descendant of an E element.

    my $headlines = $dom.find('div h1');

=head2 E > F

An F element child of an E element.

    my $headlines = $dom.find('html > body > div > h1');

=head2 E + F

An F element immediately preceded by an E element.

    my $second = $dom.find('h1 + h2');

=head2 E ~ F

An F element preceded by an E element.

    my $second = $dom.find('h1 ~ h2');

=head2 E, F, G

Elements of type E, F and G.

    my $headlines = $dom.find('h1, h2, h3');

=head2 E[foo=bar][bar=baz]

An E element whose attributes match all following attribute selectors.

    my $links = $dom.find('a[foo^=b][foo$=ar]');

=head1 OPERATORS AND COERCIONS

You can use array subscripts and hash subscripts with DOM::Tiny. Using this
class as an array or hash, though, is not recommended as several of the standard
methods for these do not work as expected.

=head2 Array

You may use array subscripts as a shortcut for calling C<children>:

    my $third-child = $dom[2];

=head2 Hash

You may use hash subscripts as a shortcut for calling C<attr>:

    my $id = $dom<id>;

=head2 Str

If you convert the DOM::Tiny object to a string using C<Str>, C<~>, or putting
it in a string, it will render the markup.

    my $html = "$dom";

=head1 METHODS

=head2 new

    method new(DOM::Tiny:U: Bool :$xml) returns DOM::Tiny:D

Constructs a DOM::Tiny object with an empty DOM tree. Setting the optional
C<$xml> flag guarantees XML mode. Setting it to a false guarantees HTML mode. If
it is unset, DOM::Tiny will select a mode based upon the parsed text, defaulting
to HTML.

=head2 parse

    method parse(DOM::Tiny:U: Str $ml, Bool :$xml) returns DOM::Tiny:D
    method parse(DOM::Tiny:D: Str $ml, Bool :$xml) returns DOM::Tiny:D

Parses the given string, C<$ml>, as HTML or XML based upon the C<$xml> flag or
autodetection if the flag is not given. If called on an existing DOM::Tiny
object, the newly parsed tree will replace the previous tree.

=head2 postcircumfix:<{}>

    method postcircumfix:<{}>(DOM::Tiny:D: Str:D $k) is rw

You may use the C<.{}> operator as a shortcut for calling the C<attr>
method and getting attributes on a tag. You may also use the C<:exists> and
C<:delete> adverbs.

=head2 hash

    method hash(DOM::Tiny:D:) returns Hash

This is a synonym for C<attr>, when it is called with no arguments.

=head2 postcircumfix:<[]>

    method postcircumfix:<[]>(DOM::Tiny:D: Int:D $i) is rw

The C<.[]> can be used in place of C<child-nodes> to retrieve children of the
current root or tag from the DOM. The C<:exists> and C<:delete> adverbs also
work.

=head2 list

    method list(DOM::Tiny:D:) returns List

This is a synonym for C<child-nodes>.

=head2 all-text

    method all-text(DOM::Tiny:D: Bool :$trim = False) returns Str

Pulls the text from all nodes under the current item in the DOM tree and returns
it as a string.  This is identical to calling C<text> with the C<:recurse> flag
set to C<True>.  The C<:trim> flag may be set to true, which will cause all
trimmable space to be clipped from the returned text (i.e., text not in an
RCDATA tag like C<title> or C<textarea> and not in a C<pre> tag).

=head2 ancestors

    method ancestors(DOM::Tiny:D: Str $selector?) returns Seq

Returns a sequence of ancestors to the current object as C<DOM::Tiny> objects.
This will return an empty sequence for the root or any node that no longer
has a parent (such as may be the case for a recently removed node).

=head2 append

    method append(DOM::Tiny:D: Str:D $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

Appends the given markup content immediately after the current node. The C<:xml>
flag may be set to determine whether the given markup should be parsed as XML or
HTML (with the default being whatever the current document is being treated as).

If the current node is the root (i.e., C<$dom.type ~~ Root>), this
operation is a no-op. It will silently do nothing.

Returns the current node.

=head2 append-content

    method append-content(DOM::Tiny:D: Str:D $ml, Bool :$xml = $!xml) returns DOM::Tiny:D

If this is the root or a tag (i.e., C<$dom.type ~~ Root|Tag>), the given markup
will be parsed and appended to the end of the root's or tag's children. If this
is a text node (i.e., C<$dom.type ~~ TextNode>), then the markup will be
appended to the text node parent's children. Otherwise this is a no-op and will
silently do nothing.

The C<:xml> flag may be used to specify the format for the markup being parsed,
defaulting to the setting for the current document.

Returns the node whose children have been modified.

=end pod

has Node $.tree = Root.new;
has Bool $.xml = False;

method DELETE-POS(DOM::Tiny:D: Int:D $i) returns DOM::Tiny {
    return Nil unless $!tree ~~ HasChildren;
    my $tree = $!tree.children[0]:delete;
    return Nil without $tree;
    $tree.parent = Nil;
    DOM::Tiny.new(:$tree, :$!xml);
}

method EXISTS-POS(DOM::Tiny:D: Int:D $i) returns Bool:D {
    return False unless $!tree ~~ HasChildren;
    $!tree.children[0]:exists
}

method AT-POS(DOM::Tiny:D: Int:D $i) is rw returns DOM::Tiny {
    return Nil unless $!tree ~~ HasChildren;
    return-rw self.child-nodes[$i]
}
method list(DOM::Tiny:D:) { self.child-nodes }

method DELETE-KEY(DOM::Tiny:D: Str:D $k) {
    return Nil unless $!tree ~~ Tag;
    $!tree.attr{$k}:delete
}

method EXISTS-KEY(DOM::Tiny:D: Str:D $k) returns Bool:D {
    return False unless $!tree ~~ Tag;
    $!tree.attr{$k}:exists
}

method AT-KEY(DOM::Tiny:D: Str:D $k) is rw {
    return Nil unless $!tree ~~ Tag;
    my $tree = self;
    Proxy.new(
        FETCH => method ()   { $tree.attr($k) },
        STORE => method ($v) { $tree.attr($k, $v) },
    );
}
method hash(DOM::Tiny:D:) { self.attr }

multi method parse(DOM::Tiny:U: Str:D $html, Bool :$xml is copy) returns DOM::Tiny:D {
    my $tree = DOM::Tiny::HTML::_parse($html, :$xml);
    $xml //= False;
    DOM::Tiny.new(:$tree, :$xml);
}

multi method parse(DOM::Tiny:D: Str:D $html, Bool :$xml) returns DOM::Tiny:D {
    $!xml  = $xml with $xml;
    $!tree = DOM::Tiny::HTML::_parse($html, :$!xml);
    self
}

multi to-json(DOM::Tiny:D $dom) is export {
    my $xml = $dom.xml // False;
    DOM::Tiny::HTML::_render($dom.tree, :$xml)
}

method all-text(DOM::Tiny:D: Bool :$trim = False) {
    $!tree.text(:recurse, :$trim);
}

method ancestors(DOM::Tiny:D: Str $selector?) {
    self!select(self.tree.ancestor-nodes, $selector);
}

method append(DOM::Tiny:D: Str:D $html, Bool :$xml is copy = $!xml) returns DOM::Tiny:D {
    if $!tree ~~ DocumentNode {
        my $i = $!tree.parent.children.first(* === $!tree, :k);
        $!tree.parent.children.splice: $i+1, 0,
            _link($!tree.parent, DOM::Tiny::HTML::_parse($html, :$xml).child-nodes)
    }

    self;
}

method append-content(DOM::Tiny:D: Str:D $html, Bool :$xml is copy = $!xml) {
    if $!tree ~~ HasChildren {
        my @children = DOM::Tiny::HTML::_parse($html, :$xml).children;
        $!tree.children.append:
            _link($!tree, DOM::Tiny::HTML::_parse($html, :$xml).children);
        self;
    }
    elsif $!tree ~~ TextNode {
        my $parent = $!tree.parent;
        $parent.children.append:
            _link($parent, DOM::Tiny::HTML::_parse($html, :$xml).children);
        $.parent;
    }
    else {
        self;
    }
}

method at(DOM::Tiny:D: Str:D $css) returns DOM::Tiny {
    if $.css.select-one($css) -> $tree {
        self.new(:$tree, :$!xml);
    }
    else {
        Nil
    }
}

multi method attr(DOM::Tiny:D: Str:D $name) returns Str {
    return Str unless $!tree ~~ Tag;
    $!tree.attr{ $name } // Str;
}

multi method attr(DOM::Tiny:D: Str:D $name, Str $value) returns DOM::Tiny:D {
    return self unless $!tree ~~ Tag;
    $!tree.attr{ $name } = $value;
    self;
}

multi method attr(DOM::Tiny:D: Str:D $name, Nil) returns DOM::Tiny:D {
    return self unless $!tree ~~ Tag;
    $!tree.attr{ $name } = Nil;
    self;
}

multi method attr(DOM::Tiny:D: *%values) {
    if %values {
        $!tree.attr{ keys %values } = values %values
            if $!tree ~~ Tag;

        self;
    }
    else {
        $!tree ~~ Tag ?? $!tree.attr !! {};
    }
}

method child-nodes(DOM::Tiny:D: Bool :$tags-only = False) {
    return () unless $!tree ~~ HasChildren;
    self!select($!tree.child-nodes(:$tags-only));
}

method children(DOM::Tiny:D: Str $css?) {
    return () unless $!tree ~~ HasChildren;
    self!select($!tree.child-nodes(:tags-only), $css);
}

multi method content(DOM::Tiny:D: DOM::Tiny:D $tree) returns DOM::Tiny:D {
    given $tree.type {
        when Root        { $!tree.content(_link($!tree, $tree.tree.children)) }
        default          { $!tree.content(_link($!tree, @=$tree)) }
    }
    self;
}

multi method content(DOM::Tiny:D: Str:D $html, Bool :$xml is copy = $!xml) returns DOM::Tiny:D {
    if $.type ~~ HasChildren {
        my $tree = DOM::Tiny::HTML::_parse($html, :$xml);
        self.content(DOM::Tiny.new(:$tree, :$xml));
    }

    # Skip parsing if we can
    else {
        $!tree.content($html);
    }

    self;
}

multi method content(DOM::Tiny:D:) is rw returns Str:D { $!tree.content }

method descendant-nodes(DOM::Tiny:D:) {
    return () unless $!tree ~~ HasChildren;
    self!select($!tree.descendant-nodes);
}
method find(DOM::Tiny:D: Str:D $css) {
    $.css.select($css).map({
        DOM::Tiny.new(tree => $_, :$!xml)
    });
}
method following(DOM::Tiny:D: Str $css?) {
    self!select(self!siblings(:tags-only)<after>, $css)
}
method following-nodes(DOM::Tiny:D:) { self!siblings()<after> }

method matches(DOM::Tiny:D: Str:D $css) returns Bool:D {
    $.css.matches($css);
}

method namespace(DOM::Tiny:D:) returns Str {
    return Nil if $!tree !~~ Tag;

    # Extract namespace prefix and search parents
    my $ns = $!tree.tag ~~ /^ (.*?) ':' / ?? "xmlns:$/[0]" !! Str;
    for flat $!tree, $!tree.ancestor-nodes -> $node {
        # Namespace for prefix
        with $ns {
            for $node.attr.kv -> $name, $value {
                return $value if $name ~~ $ns;
            }
        }
        orwith $node.attr<xmlns> {
            return $node.attr<xmlns>;
        }
    }

    return Str;
}

method next(DOM::Tiny:D:) {
    self!maybe(self!siblings(:tags-only, :pos(0))<after>);
}

method next-node(DOM::Tiny:D:) {
    self!maybe(self!siblings(:pos(0))<after>);
}

method parent(DOM::Tiny:D:) returns DOM::Tiny {
    if $!tree ~~ Root {
        Nil
    }
    else {
        self.new(:tree($!tree.parent), :$!xml);
    }
}

method preceding(DOM::Tiny:D: Str $css?) {
    self!select(self!siblings(:tags-only)<before>, $css);
}
method preceding-nodes(DOM::Tiny:D:) {
    self!siblings()<before>;
}

method prepend(DOM::Tiny:D: Str:D $html, Bool :$xml is copy = $!xml) returns DOM::Tiny:D {
    if $!tree ~~ DocumentNode {
        my $i = $!tree.parent.children.first(* === $!tree, :k);
        $!tree.parent.children.splice: $i, 0,
            _link($!tree.parent, DOM::Tiny::HTML::_parse($html, :$xml).child-nodes);
    }

    self;
}
method prepend-content(DOM::Tiny:D: Str:D $html, Bool :$xml is copy = $!xml) {
    if $!tree ~~ HasChildren {
        $!tree.children.prepend:
            _link($!tree, DOM::Tiny::HTML::_parse($html, :$xml).child-nodes);
        self;
    }
    elsif $!tree ~~ TextNode {
        my $parent = $!tree.parent;
        $parent.children.prepend:
            _link($parent, DOM::Tiny::HTML::_parse($html, :$xml).children);
        $.parent;
    }
    else {
        self;
    }
}

method previous(DOM::Tiny:D:) {
    self!maybe(self!siblings(:tags-only, :pos(*-1))<before>);
}
method previous-node(DOM::Tiny:D:) {
    self!maybe(self!siblings(:pos(*-1))<before>);
}

method remove(DOM::Tiny:D:) { self.replace('') }

multi method replace(DOM::Tiny:D: Str:D $html) {
    self.replace(DOM::Tiny.parse($html, :$!xml));
}

multi method replace(DOM::Tiny:D: DOM::Tiny:D $tree) {
    if $!tree ~~ Root {
        $!tree = $tree.tree;
        self;
    }
    else {
        self!replace: $!tree.parent, $!tree, $tree.tree.child-nodes;
        $.parent;
    }
}

method root(DOM::Tiny:D:) {
    $!tree ~~ Root ?? self !! DOM::Tiny.new(:tree($!tree.root), :$!xml);
}

method strip(DOM::Tiny:D:) {
    if $!tree ~~ Tag {
        self!replace: $!tree.parent, $!tree, $!tree.child-nodes;
    }
    else {
        self;
    }
}

multi method tag(DOM::Tiny:D:) returns Str {
    $!tree ~~ Tag ?? $!tree.tag !! Nil
}

multi method tag(DOM::Tiny:D: Str:D $tag) returns DOM::Tiny:D {
    if $!tree ~~ Tag {
        $!tree.tag = $tag;
    }
    self;
}

method text(DOM::Tiny:D: Bool :$trim = False, Bool :$recurse = False) {
    $!tree.text(:$trim, :$recurse);
}
method render(DOM::Tiny:D:) {
    $!tree.render(:$!xml);
}
multi method Str(DOM::Tiny:D:) { self.render }

method type(DOM::Tiny:D:) { $!tree.WHAT }

my multi _val(Tag, 'option', $dom) { $dom<value> // $dom.text }
my multi _val(Tag, 'input', $dom) {
    if $dom<type>.defined && $dom<type> eq 'radio' | 'checkbox' {
        $dom<value> // 'on';
    }
    else {
        $dom<value>
    }
}
my multi _val(Tag, 'button', $dom) { $dom<value> }
my multi _val(Tag, 'textarea', $dom) { $dom.text }
my multi _val(Tag, 'select', $dom) {
    my $v = $dom.find('option:checked').map({ .val });
    return $v if $dom<multiple>:exists;
    $v[*-1] // Nil
}
my multi _val($, $, $dom) { Nil }

method val(DOM::Tiny:D:) {
    _val($.type, $.tag, self);
}

method wrap(DOM::Tiny:D: Str:D $html, Bool :$xml = $!xml) {
    return self if $!tree ~~ Root;
    _wrap($!tree.parent, ($!tree,), $html, :$xml);
    self
}
method wrap-content(DOM::Tiny:D: Str:D $html, Bool :$xml = $!xml) {
    _wrap($!tree, $!tree.children, $html, :$xml) if $!tree ~~ HasChildren;
    self
}

method css(DOM::Tiny:D:) { DOM::Tiny::CSS.new(:$!tree) }

my sub _link($parent, @children) {

    # Link parent to children
    for @children -> $node {
        $node.parent = $parent;
    }

    return @children;
}

method !maybe($tree) {
    $tree ?? DOM::Tiny.new(:$tree, :$!xml) !! Nil
}

method !replace($parent, $child, @nodes) {
    my $i = $parent.children.first({ $child === $_ }, :k);
    $parent.children.splice: $i, 1, _link($parent, @nodes);
    $.parent;
}

method !select($collection, $selector?) {
    my $list := $collection.map: { DOM::Tiny.new(:$^tree, :$!xml) };
    if $selector {
        $list.grep({ .matches($selector) });
    }
    else {
        $list
    }
}

method !siblings(:$tags-only = False, :$pos) {
    my %split = do if $!tree ~~ DocumentNode {
        $!tree.split-siblings(:$tags-only);
    }
    else {
        { before => [], after => [] },
    }

    with $pos {
        for <before after> -> $k {
            %split{$k} = %split{$k}[$pos] ?? %split{$k}[$pos] !! Nil;
        }
    }

    %split;
}

my sub _wrap($parent, @nodes is copy, $html, :$xml! is copy) {
    my $innermost = my $wrapper = DOM::Tiny::HTML::_parse($html, :$xml);
    while $innermost.child-nodes(:tags-only)[0] -> $next-inner {
        $innermost = $next-inner;
    }

    return if $innermost ~~ Root;

    $innermost.children.append: _link($innermost, @nodes);
    my $i = $parent.children.first({ $_ === any(|@nodes) }, :k) // *;
    $parent.children.splice: $i, 0, _link($parent, $wrapper.children);
    $parent.children .= grep(none(|@nodes));
}
