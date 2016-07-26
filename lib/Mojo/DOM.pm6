unit class Mojo::DOM;
use v6;

use Mojo::DOM::CSS;
use Mojo::DOM::HTML;

my package EXPORT::DEFAULT {
    for < Root Text Tag Raw PI Doctype Comment CDATA DocumentNode Node HasChildren TextNode > -> $type {
        OUR::{ "$type" } := Mojo::DOM::HTML::{ $type };
    }
}

has Node $.tree = Root.new;
has Bool $.xml;

multi method Bool(Mojo::DOM:U:) returns Bool:D { False }
multi method Bool(Mojo::DOM:D:) returns Bool:D { True }

method AT-POS(Mojo::DOM:D: Int:D $i) is rw { self.child-nodes[$i] }
method list(Mojo::DOM:D:) { self.child-nodes }

method AT-KEY(Mojo::DOM:D: Str:D $k) is rw {
    Proxy.new(
        FETCH => method ()   { self.attr($k) },
        STORE => method ($v) { self.attr($k, $v) },
    );
}
method hash(Mojo::DOM:D:) { self.attr }

multi method parse(Mojo::DOM:U: Str:D $html, Bool :$xml) returns Mojo::DOM:D {
    my $tree = Mojo::DOM::HTML::_parse($html, :$xml);
    Mojo::DOM.new(:$tree, :$xml);
}

multi method parse(Mojo::DOM:D: Str:D $html, Bool :$xml) returns Mojo::DOM:D {
    $!xml  = $xml with $xml;
    $!tree = Mojo::DOM::HTML::_parse($html, :$!xml);
    self
}

multi to-json(Mojo::DOM:D $dom) is export {
    my $xml = $dom.xml // False;
    Mojo::DOM::HTML::_render($dom.tree, :$xml)
}

method all-text(Mojo::DOM:D: Bool :$trim = True) {
    $!tree.text(:recurse, :$trim);
}

method ancestors(Mojo::DOM:D: Str $selector?) {
    self!select(self.tree.ancestor-nodes, $selector);
}

method append(Mojo::DOM:D: Str:D $html) returns Mojo::DOM:D {
    if $!tree ~~ DocumentNode {
        $!tree.parent.children.append:
            _link($!tree.parent, Mojo::DOM::HTML::_parse($html).child-nodes)
    }

    self;
}

method append-content(Mojo::DOM:D: Str:D $html) {
    if $!tree ~~ HasChildren {
        my @children = Mojo::DOM::HTML::_parse($html, :$!xml).children;
        $!tree.children.append:
            _link($!tree, Mojo::DOM::HTML::_parse($html, :$!xml).children);
    }

    self;
}

method at(Mojo::DOM:D: Str:D $css) returns Mojo::DOM {
    if $.css.select-one($css) -> $tree {
        self.new(:$tree, :$!xml);
    }
    else {
        Nil
    }
}

multi method attr(Mojo::DOM:D: Str:D $name) returns Str {
    $.attr{ $name } // Str;
}

multi method attr(Mojo::DOM:D: Str:D $name, Str:D $value) returns Mojo::DOM:D {
    $.attr{ $name } = $value;
    self;
}

multi method attr(Mojo::DOM:D: *%values) {
    return $!tree !~~ Tag ?? {} !! $!tree.attrs unless %values;
    $.attr{ keys %values } = values %values;
    self;
}

method child-nodes(Mojo::DOM:D: Bool :$tags-only = False) {
    self!select($!tree.child-nodes(:$tags-only));
}

method children(Mojo::DOM:D: Str $css?) {
    self!select($!tree.child-nodes(:tags-only), $css);
}

multi method content(Mojo::DOM:D: Str:D $html) returns Mojo::DOM:D {
    $!tree.content = $html;
    self;
}

multi method content(Mojo::DOM:D:) is rw returns Str:D { $!tree.content }

method descendant-nodes(Mojo::DOM:D:) {
    self!select($!tree.descendant-nodes);
}
method find(Mojo::DOM:D: Str:D $css) {
    $.css.select($css).map({
        Mojo::DOM.new(tree => $_, :$!xml)
    });
}
method following(Mojo::DOM:D: Str:D $css) {
    self!select(self!siblings(:tags-only)<after>, $css)
}
method following-nodes(Mojo::DOM:D:) { self!siblings()<after> }

method matches(Mojo::DOM:D: Str:D $css) { $.css.matches($css) }

method namespace(Mojo::DOM:D:) returns Str {
    return Nil if $!tree !~~ Tag;

    # Extract namespace prefix and search parents
    my $ns = $!tree.tag ~~ /^ (.*?) ':' / ?? "xmlns:$/[0]" !! Str;
    for $!tree.ancestors -> $node {
        # Namespace for prefix
        with $ns {
            for $node.attrs.kv -> $name, $value {
                return $value if $name ~~ $ns;
            }
        }
        orwith $node.attrs<xmlns> {
            return $node.attrs<xmlns>;
        }
    }

    return Str;
}

method next(Mojo::DOM:D:) {
    self!maybe(self!siblings(:tags-only, :pos(0))<after>);
}

method next-node(Mojo::DOM:D:) {
    self!maybe(self!siblings(:pos(0))<after>);
}

method parent(Mojo::DOM:D:) returns Mojo::DOM {
    if $!tree ~~ Root {
        Nil
    }
    else {
        self.new(:tree($!tree.parent), :$!xml);
    }
}

method preceding(Mojo::DOM:D: Str:D $css) {
    self!select(self!siblings(:tags-only)<before>, $css);
}
method preceding-nodes(Mojo::DOM:D:) {
    self!siblings()<before>;
}

method prepend(Mojo::DOM:D: Str:D $html) returns Mojo::DOM:D {
    if $!tree ~~ DocumentNode {
        $!tree.parent.children.append:
            _link($!tree.parent, Mojo::DOM::HTML::_parse($html).child-nodes);
    }

    self;
}
method prepend-content(Mojo::DOM:D: Str:D $html) {
    if $!tree ~~ HasChildren {
        $!tree.children.append:
            _link($!tree, Mojo::DOM::HTML::_parse($html).child-nodes);
    }

    self;
}

method previous(Mojo::DOM:D:) {
    self!maybe(self!siblings(:tags-only, :pos(*-1))<before>);
}
method previous-node(Mojo::DOM:D:) {
    self!maybe(self!siblings(:pos(*-1))<before>);
}

method remove(Mojo::DOM:D:) { self.replace('') }

method replace(Mojo::DOM:D: Str:D $html) {
    if $!tree ~~ Root {
        self.parse($html);
    }
    else {
        self!replace: $!tree.parent, $!tree,
            Mojo::DOM::HTML::_parse($html).child-nodes
    }
}

method root(Mojo::DOM:D:) { $!tree ~~ Root ?? self !! $!tree.root }

method strip(Mojo::DOM:D:) {
    if $!tree ~~ Tag {
        self!replace: $!tree.children, $!tree, $!tree.child-nodes;
    }
    else {
        self;
    }
}

multi method tag(Mojo::DOM:D:) returns Str {
    $!tree ~~ Tag ?? $!tree.tag !! Nil
}

multi method tag(Mojo::DOM:D: Str:D $tag) returns Mojo::DOM:D {
    if $!tree ~~ Tag {
        $!tree.tag = $tag;
    }
    self;
}

method text(Mojo::DOM:D: Bool :$trim, Bool :$recurse) {
    $!tree.text(:$trim, :$recurse);
}
method render(Mojo::DOM:D:) {
    $!tree.render(:$!xml);
}
multi method Str(Mojo::DOM:D:) { self.render }

method type(Mojo::DOM:D:) { $!tree.WHAT }

my multi _val(Tag, 'option', $dom) { $dom<value> // $dom.text }
my multi _val(Tag, 'input', $dom) {
    if $dom<type> eq 'radio' | 'checkbox' {
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
    $dom<multiple>:exists ?? $v !! $v[*]
}
my multi _val($, $, $dom) { Nil }

method val(Mojo::DOM:D:) returns Str {
    _val($.type, $.tag, self);
}

method wrap(Mojo::DOM:D: Str:D $html) {
    _wrap($!tree.parent, $!tree, $html);
    self
}
method wrap-content(Mojo::DOM:D: Str:D $html) {
    _wrap($!tree, $!tree.children, $html);
    self
}

method css(Mojo::DOM:D:) { Mojo::DOM::CSS.new(:$!tree) }

my sub _link($parent, @children) {

    # Link parent to children
    for @children -> $node {
        $node.parent = $parent;
    }

    return @children;
}

method !maybe($tree) {
    $tree ?? Mojo::DOM.new(:$tree, :$!xml) !! Nil
}

method !replace($parent, $child, @nodes) {
    my $i = $parent.children.first({ $child === $_ }, :k);
    $parent.children.splice: $i, 1, _link($parent, @nodes);
    $.parent;
}

method !select($collection, $selector?) {
    my $list := do if $selector {
        $collection.grep: { .matches($selector) };
    }
    else {
        $collection;
    };

    $list.map: { Mojo::DOM.new(:$^tree, :$!xml) };
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

my sub _wrap($parent, @nodes, $html) {
    my $innermost = my $wrapper = Mojo::DOM::HTML::_parse($html);
    while $innermost.child-nodes(:tags-only)[0] -> $next-inner {
        $innermost = $next-inner;
    }

    if $innermost !=== $wrapper {
        push $innermost.children, _link($innermost, @nodes);
        my $i = $parent.children.first({ $_ === any(|@nodes) }, :v) // *;
        $parent.children.splice: $i, 0, _link($parent, @nodes);
        $parent.children .= grep({ $_ !=== any(|@nodes) });
    }
}
