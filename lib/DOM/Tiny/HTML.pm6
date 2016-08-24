unit module DOM::Tiny::HTML;
use v6;

use DOM::Tiny::Entities;

grammar XMLTokenizer {
    token TOP { <ml-token>* }

    token ml-token { <markup> }

    proto token markup { * }
    token markup:sym<doctype> { :i '<!DOCTYPE' <.ws> <doctype> <.ws> '>' }
    token markup:sym<comment> { '<!--' $<comment> = [ .*? ] '--' <.ws> '>' }
    token markup:sym<cdata> { '<![CDATA[' $<cdata> = [ .*? ] ']]>' }
    token markup:sym<pi> { '<?' $<pi> = [ .*? ] '?>' }
    token markup:sym<tag> {
        '<' <.ws> <end-mark>? <.ws> <tag-name> <.ws>
        [ <attr> <.ws> ]* <.ws> <empty-tag-mark>? '>'
    }
    token markup:sym<text> { <-[ < ]>+ }

    rule doctype {
        <root-element>
        [ <pub-priv>? <external-id> +% <.ws> ]?
        [ '[' <internal-subset> ']' ]?
    }
    token root-element { \w+ }
    token pub-priv { \w+ }
    token external-id { '"' <-["]>* '"' | "'" <-[']>* "'" }
    token doctype-uri { <-[ \] ]>+ }
    token internal-subset { <-[ \] ]>+ }

    token end-mark { '/' }
    token empty-tag-mark { '/' }
    token tag-name { <-[ < > \s / ]>+ }

    rule attr {
        || <attr-key> [ '=' <attr-value> ]?
        || <attr-broken> [ '=' <attr-value> ]?
    }
    token attr-key { <-[ < > = \s / ]>+ }
    token attr-value {
        | [ '"' $<raw-value> = [ .*? ] '"'  ]
        | [ "'" $<raw-value> = [ .*? ] "'" ]
        | [ $<raw-value> = <-[ > \s ]>* ]
    }
    token attr-broken {
        [
        | <-[ \s < > = / ]>
        | '/' <!before <.ws> '>' >
        ]+
    }
}

grammar HTMLTokenizer is XMLTokenizer {
    token tag-name {
        <!before <.raw-tag> | <.rcdata-tag> > <-[ < > \s / ]>+
    }

    token markup:sym<rcdata> { :i
        '<' <.ws> $<start> = <rcdata-tag> <.ws>
        [ <attr> <.ws> ]* <.ws> '>'
        { $ = $<start> } # Why does this fix the regex?
        $<rcdata-text> = [ .*? ]
        [
            | '<' <.ws> '/' <.ws> "$<start>" <.ws> '>'
            | $
        ]
    }

    token markup:sym<raw> { :i
        '<' <.ws> $<start> = <raw-tag> <.ws>
        [ <attr> <.ws> ]* <.ws> '>'
        { $ = $<start> } # Why does this fix the regex?
        $<raw-text> = [ .*? ]
        [
            | '<' <.ws> '/' <.ws> "$<start>" <.ws> '>'
            | $
        ]
    }

    token rcdata-tag { :i [ title | textarea ] }
    token raw-tag { :i [ script | style ] }

    token ml-token { <markup> || <runaway-lt> }
    token runaway-lt { '<' }
}

# HTML elements that only contain raw text
my %RAW = set <script style>;

# HTML elements that only contain raw text and entities
my %RCDATA = set <title textarea>;

# HTML elements with optional end tags
my %END = body => 'head', optgroup => 'optgroup', option => 'option';

# HTML elements that break paragraphs
%END{$_} = 'p' for <
  address article aside blockquote dir div dl fieldset footer form h1 h2
  h3 h4 h5 h6 header hr main menu nav ol p pre section table ul
>;

# HTML table elements with optional end tags
my %TABLE = set <colgroup tbody td tfoot th thead tr>;

# HTML elements with optional end tags and scoping rules
my %CLOSE = li => ((set <li>), (set <ul ol>)),
            tr => ((set <tr>), (set <table>));
%CLOSE{$_} = %TABLE, (set <table>) for <colgroup tbody tfoot thead>;
%CLOSE{$_} = (set <dd dt>), (set <dl>) for <dd dt>;
%CLOSE{$_} = (set <rp rt>), (set <ruby>) for <rp rt>;
%CLOSE{$_} = (set <th td>), (set <table>) for <td th>;

# HTML elements without end tags
my %EMPTY = set <
  area base br col embed hr img input keygen link menuitem meta param
  source track wbr
>;

# HTML elements categorized as phrasing content (and obsolete inline elements)
my @PHRASING = <
  a abbr area audio b bdi bdo br button canvas cite code data datalist
  del dfn em embed i iframe img input ins kbd keygen label link map mark
  math meta meter noscript object output picture progress q ruby s samp
  script select slot small span strong sub sup svg template textarea time u
  var video wbr
>;
my @OBSOLETE = < acronym applet basefont big font strike tt >;
my %PHRASING = set @OBSOLETE, @PHRASING;

# HTML elements that don't get their self-closing flag acknowledged
my %BLOCK = set <
  a address applet article aside b big blockquote body button caption
  center code col colgroup dd details dialog dir div dl dt em fieldset
  figcaption figure font footer form frameset h1 h2 h3 h4 h5 h6 head
  header hgroup html i iframe li listing main marquee menu nav nobr
  noembed noframes noscript object ol optgroup option p plaintext pre rp
  rt s script section select small strike strong style summary table
  tbody td template textarea tfoot th thead title tr tt u ul xmp
>;

my class Runaway { }
class Node is export {
    method render(:$xml) { ... }
    method Str { self.render }
}

class Root { ... }
class Tag { ... }
role HasChildren { ... }

class DocumentNode is export is Node {
    has HasChildren $.parent is rw;

    method root(DocumentNode:D:) {
        given $!parent {
            when not .defined { Nil }
            when Root         { $!parent }
            default           { $!parent.root }
        }
    }

    method ancestor-nodes(DocumentNode:D: Bool :$root = False, Bool :$context = False) {
        return () if $context && $*TREE-CONTEXT && self === $*TREE-CONTEXT;

        my $parent = $!parent;
        gather repeat {
            take $parent if $parent ~~ DocumentNode || $root;
            last if $context && $parent === $*TREE-CONTEXT;
        } while $parent ~~ DocumentNode &&
              ?($parent = $parent.parent);
    }

    method trimmable(DocumentNode:D:) returns Bool:D {
        $.parent.trimmable
    }

    method siblings(DocumentNode:D: Bool :$tags-only = False, Bool :$including-self = True) {
        my $siblings = $!parent.child-nodes(:$tags-only);
        $siblings.=grep({ $_ !=== self }) unless $including-self;
        $siblings.list
    }

    method split-siblings(DocumentNode:D: Bool :$tags-only) {
        my @us = $!parent.child-nodes;
        my $pos = @us.first({ $_ === self }, :k);

        my %result = before => @us[0 .. $pos - 1],
                     after  => @us[$pos + 1 .. *];

        if $tags-only {
            %result<before> .= grep(Tag);
            %result<after>  .= grep(Tag);
        }

        %result;
    }
}

class Text { ... }
role TextNode { ... }

role HasChildren is export {
    has DocumentNode @.children is rw;

    method descendant-nodes(HasChildren:D: Bool :$tags-only = False) {
        flat self.child-nodes(:$tags-only).map(-> $node {
            if $node.WHAT ~~ Tag {
                ($node, $node.descendant-nodes(:$tags-only))
            }
            else {
                $node
            }
        });
    }

    method child-nodes(HasChildren:D: Bool :$tags-only = False) {
        if $tags-only {
            @!children.grep(Tag);
        }
        else {
            @!children;
        }
    }

    multi method content(HasChildren:D:) {
        self.render-children;
    }

    multi method content(HasChildren:D: Str:D $html) {
        my $xml;
        my $tree = DOM::Tiny::HTML::_parse($html, :$xml);
        @!children = $tree.children;
    }

    multi method content(HasChildren:D: Node:D @children) {
        @!children = @children;
    }

    method !read-text(:$recurse, :$trim is copy) {
        $trim &&= self.trimmable;

        my $i = 0;
        MERGE: while @!children[$i + 1] -> $next {
            if @!children[$i] ~~ Text && $next ~~ Text {
                splice @!children, $i, 2, Text.new(
                    text   => @!children[$i].text ~ $next.text,
                    parent => self,
                );
                next MERGE;
            }

            $i++;
        }

        my @nodes = $recurse ?? self.descendant-nodes !! self.child-nodes;

        my $previous-chunk = '';
        [~] gather for @nodes -> $node {
            next unless $node ~~ TextNode;
            my $chunk = $node.text(:$trim);
            next if $chunk.chars == 0;

            if $previous-chunk ~~ / \S $ / && $chunk ~~ /^ <-[ . ! ? , ; : \s ]>+ / {
                take " $chunk";
            }
            else {
                take $chunk;
            }

            $previous-chunk = $chunk;
        }
    }

    method text(HasChildren:D: Bool :$recurse = False, Bool :$trim = False) is rw {
        my $tree = self;
        Proxy.new(
            FETCH => method ()   { $tree!read-text(:$recurse, :$trim) },
            STORE => method ($t) {
                @!children = Text.new(text => $t);
            },
        );
    }

    method render-children(:$xml) { [~] @!children.map({ .render(:$xml) }); }
}

role TextNode is export {
    has Str $.text is rw = '';

    method !squished-text { $!text.trim.subst(/\s+/, ' ', :global) }

    multi method text(TextNode:D: Bool :$trim is copy = False) {
        $trim &&= self.trimmable;
        $trim ?? self!squished-text !! $!text
    }

    multi method text(TextNode:D:) is rw { return-rw $!text }

    multi method content(TextNode:D:) { $!text }
    multi method content(TextNode:D: Str:D $text) { $!text = $text }
    multi method content(TextNode:D: Node:D @children) { $!text = [~] @children».Str }
}

class CDATA is export is DocumentNode does TextNode {
    method trimmable(CDATA:D:) { False }
    method render(:$xml) { '<![CDATA[' ~ $.text ~ ']]>' }
}

class Comment is export is DocumentNode {
    has Str $.comment is rw = '';

    multi method content(Comment:D:) { $!comment }
    multi method content(Comment:D: Str:D $text) { $!comment = $text }
    multi method content(Comment:D: Node:D @children) { $!comment = [~] @children».Str }

    method render(:$xml) { '<!--' ~ $!comment ~ '-->' }
}

class Doctype is export is DocumentNode {
    has Str $.doctype is rw = '';

    multi method content(Doctype:D:) { $!doctype }
    multi method content(Doctype:D: Str:D $text) { $!doctype = $text }
    multi method content(Doctype:D: Node:D @children) { $!doctype = [~] @children».Str }

    method render(:$xml) { '<!DOCTYPE ' ~ $!doctype ~ '>' }
}

class PI is export is DocumentNode {
    has Str $.pi is rw = '';

    multi method content(PI:D:) { $!pi }
    multi method content(PI:D: Str:D $text) { $!pi = $text }
    multi method content(PI:D: Node:D @children) { $!pi = [~] @children».Str }

    method render(:$xml) { '<?' ~ $!pi ~ '?>' }
}

class Raw is export is DocumentNode does TextNode {
    method trimmable() { False }
    method render(:$xml) { $!text }
}

class Tag is export is DocumentNode does HasChildren {
    has Str $.tag is rw is required;
    has %.attr is rw;
    has Bool $.rcdata is rw = False;

    method trimmable(Tag:D:) returns Bool {
        return False if $.rcdata;
        return False if $!tag eq 'pre';
        $.parent.trimmable;
    }

    method render(:$xml) {
        # Start tag
        my $result = "<$!tag";

        # Attributes
        $result ~= [~] gather for %!attr.sort».kv -> ($key, $value) {
            with $value {
                take qq{ $key="} ~ html-escape($value) ~ '"';
            }
            elsif $xml {
                take qq{ $key="$key"};
            }
            else {
                take " $key";
            }
        }

        # No children
        return $xml          ?? "$result />"
            !! %EMPTY{$!tag} ?? "$result>"
            !!                  "$result></$!tag>"
                unless @!children.elems > 0;

        # Children
        $result ~= '>' ~ self.render-children(:$xml);

        # End tag
        "$result\</$!tag>";
    }
}

class Text is export is DocumentNode does TextNode {
    method render(:$xml) {
        $.parent ~~ Tag
            && $.parent.rcdata ?? $!text !! html-escape $!text;
    }
}

class Root is export is Node does HasChildren {
    method trimmable(Root:D:) { True }
    method ancestor-nodes(Root:D:) { () }
    method render(:$xml) { self.render-children(:$xml) }
}

class TreeMaker {
    has Bool $.xml = False;

    my sub _end($end, $xml, $current is rw) {

        # Search stack for start tag
        my $next = $current;
        repeat {

            # Ignore useless end tag
            return if $next ~~ Root;

            # Right tag
            return $current = $next.parent if $next.tag eq $end;

            # Phrasing content can only cross phrasing content
            return if !$xml && %PHRASING{$end} && !%PHRASING{$next.tag};

        } while ?($next = $next.parent);

        # The above loop runs not without this? WTH?
        return;
    }

    my sub _start($start, %attr, $xml, $current is rw) {

        # Autoclose optional HTML elements
        if !$xml && $current !~~ Root {
            if %END{$start} -> $end {
                _end($end, False, $current);
            }
            elsif %CLOSE{$start} -> $close {
                my ($allowed, $scope) = |$close;

                # Close allowed parent elements in scope
                my $parent = $current;
                while $parent !~~ Root && $scope ∌ $parent.tag {
                    _end($parent.tag, False, $current) if $allowed ∋ $parent.tag;
                    $parent = $parent.parent;
                }
            }
        }

        # New tag
        $current.children.push: my $new = Tag.new(
            tag    => $start,
            attr   => %attr,
            parent => $current,
        );
        $current = $new;
    }

    method TOP($/) {
        my $current = my $tree = Root.new;

        my $xml = $.xml;
        for $<ml-token>».made -> %markup {
            given %markup<type> {
                when Tag {

                    if %markup<rcdata> {
                        my $start = %markup<tag>;
                        my %attr  = %markup<attr>;
                        my $text  = %markup<rcdata>;

                        _start($start, %attr, $xml, $current);
                        $current.rcdata = True;
                        $current.children = Text.new(
                            text   => html-unescape($text),
                            parent => $current,
                        );
                        _end($start, $xml, $current);
                    }

                    # End
                    elsif %markup<end> {
                        _end(%markup<tag>, $xml, $current);
                    }

                    # Start
                    else {
                        my $start   = %markup<tag>;
                        my %attr    = %markup<attr>;
                        my $closing = %markup<empty>;

                        # "image" is an alias for "img"
                        $start = 'img' if !$xml && $start eq 'image';
                        _start($start, %attr, $xml, $current);

                        # Element without end tag (self-closing)
                        _end($start, $xml, $current)
                            if (!$xml && %EMPTY ∋ $start)
                                || (($xml || %BLOCK ∌ $start) && $closing);
                    }

                }

                when Raw {
                    my $raw-tag = Tag.new(
                        tag      => %markup<tag>,
                        attr     => %markup<attr>,
                        parent   => $current,
                    );

                    $raw-tag.children.push: Raw.new(
                        text   => %markup<raw>,
                        parent => $raw-tag,
                    );

                    $current.children.push: $raw-tag;
                }

                when Doctype {
                    $current.children.push: Doctype.new(
                        doctype => %markup<doctype>,
                        parent => $current,
                    );
                }

                when Comment {
                    $current.children.push: Comment.new(
                        comment => %markup<comment>,
                        parent  => $current,
                    );
                }

                when CDATA {
                    $current.children.push: CDATA.new(
                        text   => %markup<cdata>,
                        parent => $current,
                    );
                }

                when Text {
                    $current.children.push: Text.new(
                        text   => html-unescape(%markup<text>),
                        parent => $current,
                    );
                }

                when PI {
                    $current.children.push: PI.new(
                        pi     => %markup<pi>,
                        parent => $current,
                    );
                }

                when Runaway {
                    $current.children.push: Text.new(
                        text   => '<',
                        parent => $current,
                    );
                }
            }
        }

        make $tree;
    }

    method ml-token($/) {
        if $<markup> {
            make $<markup>.made;
        }
        else {
            make $<runaway-lt>.made;
        }
    }

    method markup:sym<text>($/) {
        make {
            type => Text,
            text => ~$/,
        }
    }

    method markup:sym<raw>($/) {
        make {
            type  => Raw,
            tag   => (~$<start>).lc,
            attr  => Hash.new($<attr>».made.grep(*.defined)),
            raw   => ~$<raw-text>,
        };
    }

    method markup:sym<rcdata>($/) {
        make {
            type   => Tag,
            tag    => (~$<start>).lc,
            attr   => Hash.new($<attr>».made.grep(*.defined)),
            rcdata => ~$<rcdata-text>,
        };
    }

    method markup:sym<tag>($/) {
        make {
            type  => Tag,
            end   => ?$<end-mark>,
            tag   => $.xml ?? ~$<tag-name> !! (~$<tag-name>).lc,
            attr  => Hash.new($<attr>».made.grep(*.defined)),
            empty => ?$<empty-tag-mark>,
        }
    }

    method markup:sym<doctype>($/) {
        make {
            type    => Doctype,
            doctype => ~$<doctype>,
        }
    }

    method markup:sym<comment>($/) {
        make {
            type    => Comment,
            comment => ~$<comment>,
        }
    }

    method markup:sym<cdata>($/) {
        make {
            type  => CDATA,
            cdata => ~$<cdata>,
        }
    }

    method markup:sym<pi>($/) {
        make {
            type => PI,
            pi   => ~$<pi>,
        }
    }

    method runaway-lt($/) {
        make { type => Runaway }
    }

    method attr($/) {
        if $<attr-broken> {
            if not $<attr-broken>.made {
                make ();
            }
            elsif $<attr-value> {
                make $<attr-broken>.made => $<attr-value>.made;
            }
            else {
                make $<attr-broken>.made => Nil;
            }
        }
        elsif $<attr-value> {
            make $<attr-key>.made => $<attr-value>.made;
        }
        else {
            make $<attr-key>.made => Nil;
        }
    }

    # TODO It would be nicer if we had a case-insensitive hash
    method attr-key($/)    { make $!xml ?? ~$/ !! (~$/).lc }
    method attr-value($/)  { make html-unescape ~$<raw-value> }
    method attr-broken($/) {
        make (~$/).comb(/ <-[ < > = \s / ]>+ /).first(*.chars > 0)
    }
}

our sub _parse($html, Bool :$xml! is rw) {
    $xml = ?($html ~~ /^ \s* '<?xml' /) without $xml;
    my $grammar = $xml ?? XMLTokenizer !! HTMLTokenizer;
    my $actions = DOM::Tiny::HTML::TreeMaker.new(:$xml);
    $grammar.parse($html, :$actions).made;
}

