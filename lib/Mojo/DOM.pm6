unit class Mojo::DOM;
use v6;

use Mojo::DOM::CSS;
use Mojo::DOM::HTML;

my package EXPORT::DEFAULT {
    our constant MarkupType = MarkupType;
    for MarkupType.^enum_value_list -> $type {
        OUR::{ "$type" } := $type;
    }
}

has $.tree = [ Root ];
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

method all-text(Mojo::DOM:D: Bool :$trim = False) {
    self!all-text(:recurse, :$trim);
}

method ancestors(Mojo::DOM:D: Str:D $selector) {
    _select(self._ancestors, $selector);
}

method append(Mojo::DOM:D: Str:D $html) returns Mojo::DOM:D {
    self!add(1, $html);
}

method append-content(Mojo::DOM:D: Str:D $html) {
    self!content($html, :start);
}

method at(Mojo::DOM:D: Str:D $css) returns Mojo::DOM {
    if $.css.select-one($css) -> $tree {
        self.new(:$tree, :$!xml);
    }
    else {
        Nil
    }
}

multi method attr(Mojo::DOM:D:) returns Hash:D {
    $.tree[0] !~~ Tag ?? {} !! $.tree[2];
}

multi method attr(Mojo::DOM:D: Str:D $name) returns Str:D {
    $.attr{ $name };
}

multi method attr(Mojo::DOM:D: Str:D $name, Str:D $value) returns Mojo::DOM:D {
    $.attr{ $name } = $value;
    self;
}

multi method attr(Mojo::DOM:D: *%values) returns Mojo::DOM:D {
    $.attr{ keys %values } = values %values;
    self;
}

method child-nodes(Mojo::DOM:D:) { _nodes($.tree) }
method children(Mojo::DOM:D: Str:D $css) {
    _select(_nodes($.tree, :tags-only), $css);
}

multi method content(Mojo::DOM:D: Str:D $html) returns Mojo::DOM:D {
    if $.type ~~ Root || $.type ~~ Tag {
        return self!content($html, :offset);
    }

    $.tree[1] = $html;
    self;
}

multi method content(Mojo::DOM:D:) returns Str:D {
    if $.type ~~ Root || $.type ~~ Tag {
        return [~] _nodes($.tree).map(Mojo::DOM::HTML::_render(*, :$.xml))
    }

    $.tree[1];
}

method descendant-nodes(Mojo::DOM:D:) { _all(_nodes($.tree)) }
method find(Mojo::DOM:D: Str:D $css) { $.css.select($css) }
method following(Mojo::DOM:D: Str:D $css) {
    _select(self!siblings(:tags-only)<after>, $css)
}
method following-nodes(Mojo::DOM:D:) { self!siblings()<after> }

method matches(Mojo::DOM:D: Str:D $css) { $.css.matches($css) }

method namespace(Mojo::DOM:D:) returns Str {
    return Nil if $.tree[0] !~~ Tag;

    # Extract namespace prefix and search parents
    my $ns = $.tree[1] ~~ /^ (.*?) ':' / ?? "xmlns:$/[0]" !! Str;
    for flat $.tree, self!ancestors -> $node {
        # Namespace for prefix
        my $attrs = $node[2];
        with $ns {
            for $attrs.kv -> $name, $value {
                return $value if $name ~~ $ns;
            }
        }
        orwith $attrs<xmlns> {
            return $attrs<xmlns>;
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
    if $.tree[0] ~~ Root {
        Nil
    }
    else {
        self.new(:tree(self!parent), :$!xml);
    }
}

method preceding(Mojo::DOM:D: Str:D $css) {
    _select(self!siblings(:tags-only)<before>, $css);
}
method preceding-nodes(Mojo::DOM:D:) {
    self!siblings()<before>;
}

method prepend(Mojo::DOM:D: Str:D $html) returns Mojo::DOM:D {
    self!add(0, $html)
}
method prepend-content(Mojo::DOM:D: Str:D $html) {
    self!content($html);
}

method previous(Mojo::DOM:D:) {
    self!maybe(self!siblings(:tags-only, :pos(-1))<before>);
}
method previous-node(Mojo::DOM:D:) {
    self!maybe(self!siblings(:pos(-1))<before>);
}

method remove(Mojo::DOM:D:) { self.replace('') }

method replace(Mojo::DOM:D: Str:D $html) {
    if $.tree[0] ~~ Root {
        self.parse($html);
    }
    else {
        self!replace(self!parent, $.tree, _nodes(
            Mojo::DOM::HTML::_parse($html)
        ));
    }
}

method root(Mojo::DOM:D:) {
    if self!ancestors(:root) -> $tree {
        Mojo::DOM.new(:$tree, :$!xml);
    }
    else {
        self;
    }
}

method strip(Mojo::DOM:D:) {
    if $.tree[0] ~~ Tag {
        self!replace($.tree[3], $.tree, _nodes($.tree));
    }
    else {
        self;
    }
}

multi method tag(Mojo::DOM:D:) returns Str {
    $.tree[0] ~~ Tag ?? $.tree[1] !! Nil
}

multi method tag(Mojo::DOM:D: Str:D $tag) returns Mojo::DOM:D {
    if $.tree[0] ~~ Tag {
        $.tree[1] = $tag;
    }
    self;
}

method text(Mojo::DOM:D: Bool :$trim, Bool :$recurse) { self!all-text(:$trim, :$recurse); }
method render(Mojo::DOM:D:) {
    Mojo::DOM::HTML::_render($.tree, :$.xml);
}
multi method Str(Mojo::DOM:D:) { self.render }

method type(Mojo::DOM:D:) { $.tree[0] }

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
    _val($.type, $.tag, $.tree[1], $.tree[2]);
}

method wrap(Mojo::DOM:D: Str:D $html) { self!wrap($html) }
method wrap-content(Mojo::DOM:D: Str:D $html) { self!wrap($html, :content) }

method !add($offset, $new) {
    if $.tree[0] !~~ Root {
        my $parent = self!parent;
        $parent.splice:
            _offset($parent, $.tree) + $offset,
            0,
            _link($parent, _nodes(Mojo::DOM::HTML::_parse($new)));
    }

    self;
}

my sub _all(*@nodes) {
    @nodes.map: flat .[0] ~~ Tag ?? ($_, _all(_nodes($_))) !! $_;
}

method !all-text(:$recurse = False, :$trim is copy = True) {

    # is an ancestor a <pre> tag? turn off trimming
    $trim = False if (|self!ancestors, $.tree).first({
        .[0] ~~ Tag && .[1] eq 'pre'
    });

    _text([_nodes($.tree)], :$recurse, :$trim);
}

method !ancestors(:$root) {
    if self!parent -> $tree is copy {
        my @ancestors = gather repeat {
            take $tree;
        } while $tree[0] ~~ Tag && ?($tree = $tree[3]);
        $root ?? @ancestors[*] !! @ancestors[0 .. *-1];
    }
    else {
        ()
    }
}

method !content($new, :$start is copy = False, :$offset is copy = False) {
    if $.tree[0] ~~ Root | Tag {
        $start  = $start  ?? $.tree.elems !! _start($.tree);
        $offset = $offset ?? $.tree.end   !! 0;
        $.tree.splice: $start, $offset,
            _link($.tree, _nodes(Mojo::DOM::HTML::_parse($new)));
        self;
    }
    else {
        my $old = $.content;
        self.content($start ?? $old ~ $new !! $new ~ $old);
    }
}

method css(Mojo::DOM:D:) { Mojo::DOM::CSS.new(:$!tree) }

my sub _link($parent, @children) {

    # Link parent to children
    for @children -> $node {
        my $offset = $node[0] ~~ Tag ?? 3 !! 2;
        $node[$offset] = $parent;
    }

    return @children;
}

method !maybe($what) {
    $what ??  Mojo::DOM.new(:$what, :$!xml) !! Nil
}

my sub _nodes($tree, :$tags-only = False) {
    if $tree {
        my @nodes = $tree[_start($tree) .. *];
        $tags-only ?? @nodes.grep({ .[0] ~~ Tag }) !! @nodes;
    }
    else {
        ()
    }
}

my sub _offset($parent, $child) {
    my $i = _start($parent);
    $parent[$i .. *].first(* === $child, :k);
}

method !parent() { $.tree[$.type ~~ Tag ?? 3 !! 2] }

method !replace($parent, $child, @nodes) {
    $parent.splice: _offset($parent, $child), 1, _link($parent, @nodes);
    $.parent;
}

my sub _select($collection, $selector) {
    if $selector {
        $collection.grep: { .matches($selector) };
    }
    else {
        $collection;
    }
}

method !siblings(:$tags-only, :pos($i)) {
    if $.parent -> $parent {
        my $matched = False;
        _nodes($parent.tree).classify(-> $node {
            if $node === $.tree { $matched++; 'pivot' }
            else { $matched ?? 'after' !! 'before' }
        });
    }
    else {
        ()
    }
}

my sub _squish($str) { $str.trim.subst(/\s+/, ' ', :global); }

my sub _start($tree) { $tree[0] ~~ Root ?? 1 !! 4 }

my sub _text($nodes, :$recurse, :$trim) {
    my $i = 0;
    while $nodes[$i + 1] -> $next {

        # Merge successive text nodes
        if $nodes[$i][0] ~~ Text && $next[0] ~~ Text {
            $nodes.splice($i, 2, [ Text, $nodes[$i][1] ~ $next[1] ]);
        }
        else {
            $i++;
        }
    }

    my $text = '';
    for $nodes -> $node {
        next unless $node.elems;

        my $chunk = do given $node[0] {
            when Text        { $trim ?? _squish $node[1] !! $node[1] }
            when CDATA | Raw { $node[1] }
            when Tag {
                if $recurse {
                    _text([_nodes($node)], :recurse, :trim($node[1] ne 'pre'));
                }
                else {
                    ''
                }
            }
            default { '' }
        }

        $chunk = " $chunk" if $text ~~ / \S $ /
                           && $chunk ~~ /^ <-[ . ! ? , ; : \s ]>+ /;

        $text ~= $chunk if $chunk ~~ /\S+/ or !$trim;
    }

    $text;
}

method !wrap($content, $new) {
    my $tree = $.tree;

    return self if !$content && $tree[0] ~~ Root;
    return self if  $content && $tree[0] ~~ none(Root, Tag);

    my $current;
    my $first = my $parsed-new = Mojo::DOM.parse($new);
    while $first = (_nodes($first, :tags-only))[0] {
        $current = $first;
    }

    if $current {
        if $content {
            push $current, _link($current, _nodes($tree));
            $tree.splice: _start($tree), $tree.end, _link($tree, _nodes($parsed-new));
        }
        else {
            self!replace(self!parent, $tree, _nodes($parsed-new));
            push $current, _link($current, $tree);
        }
    }

    self
}
